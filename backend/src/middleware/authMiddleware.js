const admin = require("../config/firebase");
const User = require("../models/User");
const protect = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({
      success: false,
      error: {
        code: "auth/missing-token",
        message: "Authorization header is missing or malformed. Expected: Bearer <token>",
      },
    });
  }

  const idToken = authHeader.split(" ")[1];

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken, true);
    const { uid } = decodedToken;
    const user = await User.findOne({ firebaseUid: uid }).select(
      "-password"
    );

    if (!user) {
      return res.status(401).json({
        success: false,
        error: {
          code: "auth/user-not-found",
          message: "No local account is linked to this Firebase UID.",
        },
      });
    }

    if (!user.isActive) {
      return res.status(403).json({
        success: false,
        error: {
          code: "auth/account-disabled",
          message: "This account has been deactivated. Please contact support.",
        },
      });
    }

    req.user = {
      ...user.toObject(),
      firebaseUid: uid,
    };

    next();
  } catch (err) {
    const firebaseAuthErrors = new Set([
      "auth/id-token-expired",
      "auth/id-token-revoked",
      "auth/invalid-id-token",
      "auth/argument-error",
      "auth/user-disabled",
    ]);

    if (err.code && firebaseAuthErrors.has(err.code)) {
      const isExpiry =
        err.code === "auth/id-token-expired" ||
        err.code === "auth/id-token-revoked";

      return res.status(401).json({
        success: false,
        error: {
          code: err.code,
          message: isExpiry
            ? "Session has expired. Please re-authenticate."
            : "Invalid authentication token.",
        },
      });
    }
    console.error("[authMiddleware] Unhandled error during token verification:", err);

    return res.status(500).json({
      success: false,
      error: {
        code: "auth/internal-error",
        message: "An internal error occurred during authentication.",
      },
    });
  }
};

const restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        error: {
          code: "auth/forbidden",
          message: `Role '${req.user.role}' is not permitted to perform this action.`,
        },
      });
    }
    next();
  };
};

module.exports = { protect, restrictTo };
