const QRCode = require("qrcode");

const QR_OPTIONS = {
  errorCorrectionLevel: "H",
  margin: 2,
  width: 256,
  color: {
    dark: "#000000",
    light: "#FFFFFF",
  },
  type: "image/png",
};

const generateQRCode = async (data, options = {}) => {
  if (!data || typeof data !== "string") {
    return {
      success: false,
      error: {
        code: "qr/invalid-input",
        message: "QR code data must be a non-empty string.",
      },
    };
  }

  if (data.length > 2953) {
    return {
      success: false,
      error: {
        code: "qr/data-too-large",
        message: "Data exceeds maximum QR code capacity.",
      },
    };
  }

  try {
    const mergedOptions = {
      ...QR_OPTIONS,
      ...options,
    };

    const dataUri = await QRCode.toDataURL(data, mergedOptions);

    return {
      success: true,
      data: dataUri,
    };
  } catch (error) {
    console.error("[qrGenerator.generateQRCode] Error:", error.message);

    return {
      success: false,
      error: {
        code: "qr/generation-failed",
        message: "Failed to generate QR code.",
      },
    };
  }
};

const generateTokenQRCode = async (token, parcelId, options = {}) => {
  if (!token || !parcelId) {
    return {
      success: false,
      error: {
        code: "qr/missing-params",
        message: "Token and parcel ID are required.",
      },
    };
  }

  const payload = JSON.stringify({
    type: "parcel_verification",
    token: token,
    parcelId: parcelId,
    v: 1,
  });

  return generateQRCode(payload, options);
};

const generateSimpleTokenQR = async (token, options = {}) => {
  return generateQRCode(token, options);
};

module.exports = {
  generateQRCode,
  generateTokenQRCode,
  generateSimpleTokenQR,
  QR_OPTIONS,
};
