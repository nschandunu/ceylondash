const admin = require("../config/firebase");
const User = require("../models/User");

/**
 * POST /api/auth/sync
 *
 * Decodes the Firebase ID token from the Authorization header,
 * then either finds the existing MongoDB user or creates a new one
 * using the provided role and registration details.
 */
const syncUser = async (req, res) => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({
            success: false,
            error: {
                code: "auth/missing-token",
                message:
                    "Authorization header is missing or malformed. Expected: Bearer <token>",
            },
        });
    }

    const idToken = authHeader.split(" ")[1];

    let decodedToken;
    try {
        decodedToken = await admin.auth().verifyIdToken(idToken, true);
    } catch (err) {
        return res.status(401).json({
            success: false,
            error: {
                code: "auth/invalid-token",
                message: "Failed to verify Firebase token.",
            },
        });
    }

    const { uid, email } = decodedToken;

    try {
        // Check if user already exists
        let user = await User.findOne({ firebaseUid: uid });

        if (user) {
            // Returning user — update lastLoginAt
            user.lastLoginAt = new Date();
            await user.save();

            return res.status(200).json({
                success: true,
                message: "User already synced.",
                data: { user },
            });
        }

        // New user — validate required registration fields
        const { role, name, phoneNumber } = req.body;

        if (!role || !name || !phoneNumber) {
            return res.status(400).json({
                success: false,
                error: {
                    code: "sync/missing-fields",
                    message: "role, name, and phoneNumber are required for new users.",
                },
            });
        }

        // Build the user document with role-specific fields
        const userData = {
            firebaseUid: uid,
            name,
            phoneNumber,
            role,
            lastLoginAt: new Date(),
        };

        // Role-specific fields
        if (role === "user") {
            userData.defaultDeliveryAddress = req.body.defaultDeliveryAddress || "";
        } else if (role === "rider") {
            if (!req.body.vehicleType || !req.body.licensePlateNumber) {
                return res.status(400).json({
                    success: false,
                    error: {
                        code: "sync/missing-rider-fields",
                        message:
                            "vehicleType and licensePlateNumber are required for riders.",
                    },
                });
            }
            userData.vehicleType = req.body.vehicleType;
            userData.licensePlateNumber = req.body.licensePlateNumber;
        } else if (role === "admin") {
            if (!req.body.adminAccessPasscode) {
                return res.status(400).json({
                    success: false,
                    error: {
                        code: "sync/missing-admin-fields",
                        message: "adminAccessPasscode is required for admins.",
                    },
                });
            }
            userData.adminAccessPasscode = req.body.adminAccessPasscode;
        }

        user = await User.create(userData);

        return res.status(201).json({
            success: true,
            message: "User created and synced.",
            data: { user },
        });
    } catch (err) {
        console.error("[authController.syncUser] Error:", err);

        // Handle Mongoose validation errors
        if (err.name === "ValidationError") {
            const messages = Object.values(err.errors).map((e) => e.message);
            return res.status(400).json({
                success: false,
                error: {
                    code: "sync/validation-error",
                    message: messages.join(". "),
                },
            });
        }

        // Handle duplicate key errors (e.g. phone number)
        if (err.code === 11000) {
            return res.status(409).json({
                success: false,
                error: {
                    code: "sync/duplicate",
                    message: "A user with this phone number already exists.",
                },
            });
        }

        return res.status(500).json({
            success: false,
            error: {
                code: "sync/internal-error",
                message: "An internal error occurred during user sync.",
            },
        });
    }
};

module.exports = { syncUser };
