const admin = require("../config/firebase");
const User = require("../models/User");

const ALLOWED_ROLES = new Set(["rider", "client", "business"]);

const register = async (req, res) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({
      success: false,
      error: {
        code: "auth/missing-token",
        message: "Authorization header is missing or malformed.",
      },
    });
  }

  const idToken = authHeader.split(" ")[1];

  let decodedToken;
  try {
    decodedToken = await admin.auth().verifyIdToken(idToken);
  } catch (err) {
    return res.status(401).json({
      success: false,
      error: {
        code: "auth/invalid-id-token",
        message: "Invalid or expired Firebase token.",
      },
    });
  }

  const { uid, email } = decodedToken;
  const { role, name, phoneNumber, address, vehicleType, licenseNumber, businessName, businessRegNumber } = req.body;

  if (!role || !ALLOWED_ROLES.has(role)) {
    return res.status(400).json({
      success: false,
      error: {
        code: "auth/invalid-role",
        message: `Role must be one of: ${[...ALLOWED_ROLES].join(", ")}`,
      },
    });
  }

  if (!name || !phoneNumber) {
    return res.status(400).json({
      success: false,
      error: {
        code: "auth/missing-fields",
        message: "Name and phone number are required.",
      },
    });
  }

  try {
    const existingUser = await User.findOne({
      $or: [{ firebaseUid: uid }, { phoneNumber }],
    });

    if (existingUser) {
      const reason =
        existingUser.firebaseUid === uid
          ? "A profile already exists for this account."
          : "This phone number is already registered.";

      return res.status(409).json({
        success: false,
        error: { code: "auth/already-exists", message: reason },
      });
    }

    const user = await User.create({
      firebaseUid: uid,
      email,
      name,
      phoneNumber,
      role,
      address,
      ...(role === "rider" && { vehicleType, licenseNumber }),
      ...(role === "business" && { businessName, businessRegNumber }),
    });

    return res.status(201).json({
      success: true,
      data: {
        id: user._id,
        firebaseUid: user.firebaseUid,
        name: user.name,
        email: user.email,
        phoneNumber: user.phoneNumber,
        role: user.role,
      },
    });
  } catch (err) {
    if (err.name === "ValidationError") {
      const messages = Object.values(err.errors).map((e) => e.message);
      return res.status(400).json({
        success: false,
        error: { code: "auth/validation-error", message: messages.join(". ") },
      });
    }

    console.error("[authController] Registration error:", err);
    return res.status(500).json({
      success: false,
      error: {
        code: "auth/internal-error",
        message: "An internal error occurred during registration.",
      },
    });
  }
};

module.exports = { register };
