const jwt = require("jsonwebtoken");

const JWT_DEFAULTS = {
  expiresIn: "7d",
};

const generateToken = (user) => {
  if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET is not configured in environment variables");
  }

  const payload = {
    userId: user._id,
    role: user.role,
  };

  const options = {
    expiresIn: process.env.JWT_EXPIRES_IN || JWT_DEFAULTS.expiresIn,
  };

  return jwt.sign(payload, process.env.JWT_SECRET, options);
};

const verifyToken = (token) => {
  if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET is not configured in environment variables");
  }

  return jwt.verify(token, process.env.JWT_SECRET);
};

const decodeToken = (token) => {
  return jwt.decode(token);
};

const extractTokenFromHeader = (authHeader) => {
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return null;
  }
  return authHeader.slice(7);
};

module.exports = {
  generateToken,
  verifyToken,
  decodeToken,
  extractTokenFromHeader,
};