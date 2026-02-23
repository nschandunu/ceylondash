const mongoose = require("mongoose");
const Parcel = require("../models/Parcel");
const VerificationToken = require("../models/VerificationToken");
const {
  generateShortToken,
  hashToken,
  calculateExpiry,
} = require("../utils/tokenGenerator");
const { generateTokenQRCode } = require("../utils/qrGenerator");

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

module.exports = {
  generateHandoverToken,
};
