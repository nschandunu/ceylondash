const mongoose = require("mongoose");
const Parcel = require("../models/Parcel");
const VerificationToken = require("../models/VerificationToken");
const {
  generateShortToken,
  hashToken,
  calculateExpiry,
} = require("../utils/tokenGenerator");
const { generateTokenQRCode } = require("../utils/qrGenerator");
const {
  validateVerificationToken,
} = require("../services/tokenService");

const HANDOVER_TOKEN_EXPIRY_MINUTES = 15;

const generateHandoverToken = async (req, res) => {
  try {
    const { id: parcelId } = req.params;
    const userId = req.user._id;

    if (!mongoose.Types.ObjectId.isValid(parcelId)) {
      return res.status(404).json({
        success: false,
        error: {
          code: "verification/parcel-not-found",
          message: "Parcel not found.",
        },
      });
    }

    const parcel = await Parcel.findById(parcelId).lean();

    if (!parcel) {
      return res.status(404).json({
        success: false,
        error: {
          code: "verification/parcel-not-found",
          message: "Parcel not found.",
        },
      });
    }

    const userIdStr = userId.toString();
    const isReceiver = parcel.receiverId?.toString() === userIdStr;
    const isAdmin = req.user.role === "admin";

    if (!isReceiver && !isAdmin) {
      return res.status(403).json({
        success: false,
        error: {
          code: "verification/forbidden",
          message: "Only the parcel receiver can generate a handover token.",
        },
      });
    }

    const invalidStatuses = ["delivered", "cancelled", "failed"];
    if (invalidStatuses.includes(parcel.status)) {
      return res.status(400).json({
        success: false,
        error: {
          code: "verification/invalid-status",
          message: `Cannot generate token for a parcel with status: ${parcel.status}`,
        },
      });
    }

    const existingToken = await VerificationToken.findOne({
      parcelId: new mongoose.Types.ObjectId(parcelId),
      userId: userId,
      used: false,
      expiresAt: { $gt: new Date() },
    });

    await VerificationToken.deleteMany({
      parcelId: new mongoose.Types.ObjectId(parcelId),
      userId: userId,
    });

    const plainToken = generateShortToken(8);
    const hashedToken = hashToken(plainToken);
    const expiresAt = calculateExpiry(HANDOVER_TOKEN_EXPIRY_MINUTES);

    await VerificationToken.create({
      parcelId: new mongoose.Types.ObjectId(parcelId),
      userId: userId,
      tokenHash: hashedToken,
      expiresAt: expiresAt,
      used: false,
    });

    const qrResult = await generateTokenQRCode(plainToken, parcelId);

    if (!qrResult.success) {
      console.error(
        "[verificationController.generateHandoverToken] QR generation failed:",
        qrResult.error
      );

      return res.status(201).json({
        success: true,
        data: {
          token: plainToken,
          qrCode: null,
          expiresAt: expiresAt,
        },
        warning: "QR code generation failed. Use the token code directly.",
      });
    }

    return res.status(201).json({
      success: true,
      data: {
        token: plainToken,
        qrCode: qrResult.data,
      },
    });
  } catch (error) {
    console.error(
      "[verificationController.generateHandoverToken] Error:",
      error.message
    );

    if (
      error.name === "MongooseError" ||
      error.message.includes("timed out") ||
      error.message.includes("buffering timed out")
    ) {
      return res.status(503).json({
        success: false,
        error: {
          code: "verification/service-unavailable",
          message:
            "Database service temporarily unavailable. Please try again.",
        },
      });
    }

    if (error.code === 11000) {
      return res.status(409).json({
        success: false,
        error: {
          code: "verification/conflict",
          message: "Token generation conflict. Please try again.",
        },
      });
    }

    return res.status(500).json({
      success: false,
      error: {
        code: "verification/internal-error",
        message: "An unexpected error occurred while generating the token.",
      },
    });
  }
};

const validateHandoverToken = async (req, res) => {
  try {
    const { id: parcelId } = req.params;
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        error: {
          code: "verification/missing-token",
          message: "Verification token is required.",
        },
      });
    }

    if (!mongoose.Types.ObjectId.isValid(parcelId)) {
      return res.status(404).json({
        success: false,
        error: {
          code: "verification/parcel-not-found",
          message: "Parcel not found.",
        },
      });
    }

    const parcel = await Parcel.findById(parcelId);
    if (!parcel) {
      return res.status(404).json({
        success: false,
        error: {
          code: "verification/parcel-not-found",
          message: "Parcel not found.",
        },
      });
    }

    // Only the assigned rider (or admin) may validate a handover token
    const userIdStr = req.user._id.toString();
    const isRider = parcel.assignedRiderId?.toString() === userIdStr;
    const isAdmin = req.user.role === "admin";

    if (!isRider && !isAdmin) {
      return res.status(403).json({
        success: false,
        error: {
          code: "verification/forbidden",
          message: "Only the assigned rider can validate a handover token.",
        },
      });
    }

    const result = await validateVerificationToken(parcelId, token, req.user);

    if (!result.success) {
      return res.status(400).json({
        success: false,
        error: result.error,
      });
    }

    // Token valid — mark parcel as delivered
    parcel.status = "delivered";
    parcel.statusHistory.push({
      status: "delivered",
      updatedAt: new Date(),
    });
    await parcel.save();

    return res.status(200).json({
      success: true,
      data: {
        verified: true,
        parcelId,
        status: "delivered",
        verifiedAt: result.data.verifiedAt,
      },
    });
  } catch (error) {
    console.error(
      "[verificationController.validateHandoverToken] Error:",
      error.message
    );

    if (
      error.name === "MongooseError" ||
      error.message.includes("timed out") ||
      error.message.includes("buffering timed out")
    ) {
      return res.status(503).json({
        success: false,
        error: {
          code: "verification/service-unavailable",
          message:
            "Database service temporarily unavailable. Please try again.",
        },
      });
    }

    return res.status(500).json({
      success: false,
      error: {
        code: "verification/internal-error",
        message: "An unexpected error occurred during token validation.",
      },
    });
  }
};

module.exports = {
  generateHandoverToken,
  validateHandoverToken,
};
