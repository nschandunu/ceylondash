"use strict";

const QRCode = require("qrcode");

const DEFAULT_QR_OPTIONS = {
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
  if (!data || typeof data !== "string" || data.trim().length === 0) {
    throw new Error("generateQRCode: data must be a non-empty string.");
  }
  const mergedOptions = { ...DEFAULT_QR_OPTIONS, ...options };
  return QRCode.toDataURL(data, mergedOptions);
};

const generateTokenQRCode = async (token, parcelId, options = {}) => {
  try {
    if (!token || !parcelId) {
      throw new Error("Both token and parcelId are required.");
    }

    const payload = JSON.stringify({ token, parcelId });
    const dataUri = await generateQRCode(payload, options);

    return { success: true, data: dataUri };
  } catch (error) {
    return { success: false, error: error.message };
  }
};

module.exports = {
  generateQRCode,
  generateTokenQRCode,
};
