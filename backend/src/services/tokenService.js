const mongoose = require("mongoose");
const VerificationToken = require("../models/VerificationToken");
const Parcel = require("../models/Parcel");
const {
  generateShortToken,
  hashToken,
  verifyToken,
  calculateExpiry,
} = require("../utils/tokenGenerator");

const TOKEN_EXPIRY_MINUTES = 15;

const checkTokenGenerationPermission = async (parcelId, user) => {
  if (!mongoose.Types.ObjectId.isValid(parcelId)) {
    return {
      allowed: false,
      parcel: null,
      reason: "Invalid parcel ID format.",
    };
  }
  const parcel = await Parcel.findById(parcelId).lean();

  if (!parcel) {
    return {
      allowed: false,
      parcel: null,
      reason: "Parcel not found.",
    };
  }

  const userId = user._id.toString();
  const isSender = parcel.senderId?.toString() === userId;
  const isReceiver = parcel.receiverId?.toString() === userId;
  const isAdmin = user.role === "admin";

  if (!isSender && !isReceiver && !isAdmin) {
    return {
      allowed: false,
      parcel: null,
      reason: "You do not have permission to generate a token for this parcel.",
    };
  }

  const invalidStatuses = ["delivered", "cancelled", "failed"];
  if (invalidStatuses.includes(parcel.status)) {
    return {
      allowed: false,
      parcel,
      reason: `Cannot generate token for a parcel with status: ${parcel.status}`,
    };
  }

  return {
    allowed: true,
    parcel,
    reason: null,
  };
};

const generateVerificationToken = async (parcelId, user) => {
  const permission = await checkTokenGenerationPermission(parcelId, user);

  if (!permission.allowed) {
    return {
      success: false,
      error: {
        code: "token/permission-denied",
        message: permission.reason,
      },
    };
  }

  const userId = user._id;

  await VerificationToken.deleteMany({
    parcelId: new mongoose.Types.ObjectId(parcelId),
    userId: userId,
  });

  const plainToken = generateShortToken(8);
  const hashedToken = hashToken(plainToken);
  const expiresAt = calculateExpiry(TOKEN_EXPIRY_MINUTES);

  const verificationToken = await VerificationToken.create({
    parcelId: new mongoose.Types.ObjectId(parcelId),
    userId: userId,
    tokenHash: hashedToken,
    expiresAt: expiresAt,
    used: false,
  });

  return {
    success: true,
    data: {
      token: plainToken,
      expiresAt: expiresAt,
      expiresIn: TOKEN_EXPIRY_MINUTES * 60,
      parcelId: parcelId,
    },
  };
};

const validateVerificationToken = async (parcelId, plainToken, user) => {
  if (!mongoose.Types.ObjectId.isValid(parcelId)) {
    return {
      success: false,
      error: {
        code: "token/invalid-parcel",
        message: "Invalid parcel ID.",
      },
    };
  }

  const tokenRecord = await VerificationToken.findOne({
    parcelId: new mongoose.Types.ObjectId(parcelId),
    used: false,
    expiresAt: { $gt: new Date() },
  }).select("+tokenHash");

  if (!tokenRecord) {
    return {
      success: false,
      error: {
        code: "token/not-found",
        message: "No valid token found for this parcel. It may have expired.",
      },
    };
  }

  const isValid = verifyToken(plainToken, tokenRecord.tokenHash);

  if (!isValid) {
    return {
      success: false,
      error: {
        code: "token/invalid",
        message: "Invalid verification token.",
      },
    };
  }

  const updateResult = await VerificationToken.findOneAndUpdate(
    {
      _id: tokenRecord._id,
      used: false,
    },
    {
      $set: { used: true },
    },
    { new: true }
  );

  if (!updateResult) {
    return {
      success: false,
      error: {
        code: "token/already-used",
        message: "This token has already been used.",
      },
    };
  }

  return {
    success: true,
    data: {
      verified: true,
      parcelId: parcelId,
      userId: tokenRecord.userId,
      verifiedAt: new Date(),
    },
  };
};

const invalidateParcelTokens = async (parcelId) => {
  if (!mongoose.Types.ObjectId.isValid(parcelId)) {
    return { success: false, deletedCount: 0 };
  }

  const result = await VerificationToken.deleteMany({
    parcelId: new mongoose.Types.ObjectId(parcelId),
  });

  return {
    success: true,
    deletedCount: result.deletedCount,
  };
};

module.exports = {
  generateVerificationToken,
  validateVerificationToken,
  invalidateParcelTokens,
  checkTokenGenerationPermission,
  TOKEN_EXPIRY_MINUTES,
};
