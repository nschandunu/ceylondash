const {
  generateVerificationToken,
  validateVerificationToken,
  TOKEN_EXPIRY_MINUTES,
} = require("../services/tokenService");
const { generateTokenQRCode } = require("../utils/qrGenerator");

const generateToken = async (req, res) => {
  try {
    const { parcelId } = req.params;
    const tokenResult = await generateVerificationToken(parcelId, req.user);

    if (!tokenResult.success) {
      const statusCode =
        tokenResult.error.code === "token/permission-denied" ? 403 : 400;

      return res.status(statusCode).json({
        success: false,
        error: tokenResult.error,
      });
    }

    const qrResult = await generateTokenQRCode(
      tokenResult.data.token,
      parcelId
    );

    if (!qrResult.success) {
      console.error(
        "[tokenController.generateToken] QR generation failed:",
        qrResult.error
      );

      return res.status(200).json({
        success: true,
        data: {
          token: tokenResult.data.token,
          qrCode: null,
          qrError: "QR code generation failed",
          expiresAt: tokenResult.data.expiresAt,
          expiresIn: tokenResult.data.expiresIn,
          parcelId: tokenResult.data.parcelId,
        },
      });
    }

    return res.status(201).json({
      success: true,
      data: {
        token: tokenResult.data.token,
        qrCode: qrResult.data,
        expiresAt: tokenResult.data.expiresAt,
        expiresIn: tokenResult.data.expiresIn,
        parcelId: tokenResult.data.parcelId,
      },
    });
  } catch (error) {
    console.error("[tokenController.generateToken] Error:", error.message);

    if (
      error.name === "MongooseError" ||
      error.message.includes("timed out") ||
      error.message.includes("buffering timed out")
    ) {
      return res.status(503).json({
        success: false,
        error: {
          code: "token/service-unavailable",
          message:
            "Database service temporarily unavailable. Please try again.",
        },
      });
    }

    return res.status(500).json({
      success: false,
      error: {
        code: "token/internal-error",
        message: "An unexpected error occurred while generating the token.",
      },
    });
  }
};

const validateToken = async (req, res) => {
  try {
    const { parcelId, token } = req.body;

    if (!parcelId || !token) {
      return res.status(400).json({
        success: false,
        error: {
          code: "token/missing-fields",
          message: "Both parcelId and token are required.",
        },
      });
    }

    const result = await validateVerificationToken(parcelId, token, req.user);

    if (!result.success) {
      const statusCode =
        result.error.code === "token/invalid" ||
        result.error.code === "token/not-found" ||
        result.error.code === "token/already-used"
          ? 401
          : 400;

      return res.status(statusCode).json({
        success: false,
        error: result.error,
      });
    }

    return res.status(200).json({
      success: true,
      data: result.data,
    });
  } catch (error) {
    console.error("[tokenController.validateToken] Error:", error.message);

    if (
      error.name === "MongooseError" ||
      error.message.includes("timed out") ||
      error.message.includes("buffering timed out")
    ) {
      return res.status(503).json({
        success: false,
        error: {
          code: "token/service-unavailable",
          message:
            "Database service temporarily unavailable. Please try again.",
        },
      });
    }

    return res.status(500).json({
      success: false,
      error: {
        code: "token/internal-error",
        message: "An unexpected error occurred while validating the token.",
      },
    });
  }
};

module.exports = {
  generateToken,
  validateToken,
};
