const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

const SALT_ROUNDS = 12;
const SRI_LANKAN_PHONE_REGEX = /^(?:\+94|0)?[7][0-9]{8}$/;

const normalizePhoneNumber = (phone) => {
  if (!phone) return phone;
  const cleaned = phone.replace(/\s+/g, "").trim();
  if (cleaned.startsWith("+94")) {
    return cleaned;
  }
  if (cleaned.startsWith("0")) {
    return "+94" + cleaned.slice(1);
  }
  return "+94" + cleaned;
};

const UserSchema = new mongoose.Schema(
  {
    firebaseUid: {
      type: String,
      unique: true,
      sparse: true, // allows null for users not yet linked to Firebase
      index: true,
    },

    name: {
      type: String,
      required: [true, "Name is required"],
      trim: true,
    },

    phoneNumber: {
      type: String,
      required: [true, "Phone number is required"],
      unique: true,
      trim: true,
      index: true,
      validate: {
        validator: function (v) {
          return SRI_LANKAN_PHONE_REGEX.test(v);
        },
        message: (props) =>
          `${props.value} is not a valid Sri Lankan phone number`,
      },
      set: normalizePhoneNumber,
    },

    password: {
      type: String,
      required: false, // Not required for Firebase-synced users
      minlength: [8, "Password must be at least 8 characters"],
      select: false,
    },

    role: {
      type: String,
      required: [true, "Role is required"],
      enum: {
        values: ["user", "rider", "admin"],
        message: '"{VALUE}" is not a permitted role',
      },
    },

    // --- Role-specific fields ---

    // User role
    defaultDeliveryAddress: {
      type: String,
      trim: true,
    },

    // Rider role
    vehicleType: {
      type: String,
      enum: {
        values: ["bike", "three-wheeler", "van"],
        message: '"{VALUE}" is not a valid vehicle type',
      },
    },

    licensePlateNumber: {
      type: String,
      trim: true,
    },

    // Admin role
    adminAccessPasscode: {
      type: String,
      select: false,
    },

    // --- End role-specific fields ---

    trustScore: {
      type: Number,
      default: 100,
      min: [0, "Trust score cannot drop below 0"],
      max: [100, "Trust score cannot exceed 100"],
    },

    isActive: {
      type: Boolean,
      default: true,
    },

    lastLoginAt: {
      type: Date,
    },
  },
  {
    timestamps: true,
  }
);

UserSchema.pre("save", async function () {
  if (!this.isModified("password")) {
    return;
  }

  const salt = await bcrypt.genSalt(SALT_ROUNDS);
  this.password = await bcrypt.hash(this.password, salt);
});

UserSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

const User = mongoose.model("User", UserSchema);

module.exports = User;