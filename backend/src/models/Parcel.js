const mongoose = require("mongoose");

const PARCEL_STATUSES = [
  "pending",
  "in_transit",
  "out_for_delivery",
  "delivered",
  "cancelled",
  "failed",
];

const StatusHistorySchema = new mongoose.Schema({
  status: {
    type: String,
    required: [true, "History entry status is required"],
    enum: {
      values: PARCEL_STATUSES,
      message: '"{VALUE}" is not a valid parcel status',
    },
  },

  updatedAt: {
    type: Date,
    required: [true, "History entry timestamp is required"],
    default: Date.now,
  },
});

const ParcelSchema = new mongoose.Schema(
  {
    senderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "Sender ID is required"],
      index: true,
    },

    senderName: {
      type: String,
      required: [true, "Sender name is required"],
      trim: true,
    },

    receiverId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      index: true,
    },

    assignedRiderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },

    trackingCode: {
      type: String,
      required: [true, "Tracking code is required"],
      unique: true,
      trim: true,
      index: true,
    },

    deliveryAddress: {
      type: String,
      required: [true, "Delivery address is required"],
      trim: true,
    },

    status: {
      type: String,
      required: [true, "Status is required"],
      enum: {
        values: PARCEL_STATUSES,
        message: '"{VALUE}" is not a valid parcel status',
      },
      default: "pending",
    },

    statusHistory: {
      type: [StatusHistorySchema],
      default: [],
    },

    codAmount: {
      type: Number,
      default: 0,
      min: [0, "COD amount cannot be negative"],
    },
  },
  {
    timestamps: true,
  }
);

const Parcel = mongoose.model("Parcel", ParcelSchema);

module.exports = Parcel;