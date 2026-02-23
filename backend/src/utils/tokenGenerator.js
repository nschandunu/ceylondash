const crypto = require("crypto");

const TOKEN_BYTE_LENGTH = 32;

const generateSecureToken = () => {
  const buffer = crypto.randomBytes(TOKEN_BYTE_LENGTH);
  return buffer.toString("hex");
};

const generateShortToken = (length = 8) => {
  const buffer = crypto.randomBytes(Math.ceil(length * 2));
  return buffer.toString("hex").slice(0, length).toUpperCase();
};

const hashToken = (token) => {
  return crypto.createHash("sha256").update(token).digest("hex");
};

const verifyToken = (plainToken, storedHash) => {
  const candidateHash = hashToken(plainToken);

  try {
    return crypto.timingSafeEqual(
      Buffer.from(candidateHash, "hex"),
      Buffer.from(storedHash, "hex")
    );
  } catch {
    return false;
  }
};

const calculateExpiry = (minutes = 15) => {
  return new Date(Date.now() + minutes * 60 * 1000);
};

module.exports = {
  generateSecureToken,
  generateShortToken,
  hashToken,
  verifyToken,
  calculateExpiry,
  TOKEN_BYTE_LENGTH,
};
