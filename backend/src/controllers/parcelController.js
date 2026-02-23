const mongoose = require("mongoose");
const Parcel = require("../models/Parcel");

/**
 * Helper to check if user has ownership/access to a parcel
 * @param {Object} parcel - The parcel document
 * @param {Object} user - The authenticated user from req.user
 * @returns {boolean} - True if user has access
 */
const hasParcelAccess = (parcel, user) => {
  const userId = user._id.toString();
  const isSender = parcel.senderId?.toString() === userId;
  const isReceiver = parcel.receiverId?.toString() === userId;
  const isAdmin = user.role === "admin";

  return isSender || isReceiver || isAdmin;
};

const getAllParcels = async (req, res) => {
  try {
    const userId = req.user._id;

    const parcels = await Parcel.find({
      $or: [{ senderId: userId }, { receiverId: userId }],
    })
      .select("-__v")
      .sort({ createdAt: -1 })
      .lean();

    // Explicitly convert every ObjectId to a plain string so the Flutter
    // client can deserialise them without special handling.
    const data = parcels.map((p) => ({
      ...p,
      _id:             p._id.toString(),
      senderId:        p.senderId?.toString() ?? null,
      receiverId:      p.receiverId?.toString() ?? null,
      assignedRiderId: p.assignedRiderId?.toString() ?? null,
      statusHistory:   (p.statusHistory ?? []).map((h) => ({
        ...h,
        _id: h._id?.toString(),
      })),
    }));

    return res.status(200).json({
      success: true,
      count: data.length,
      data,
    });
  } catch (error) {
    console.error("[parcelController.getAllParcels] Error:", error.message);

    if (error.name === "CastError") {
      return res.status(400).json({
        success: false,
        error: {
          code: "parcel/invalid-query",
          message: "Invalid query parameters.",
        },
      });
    }

    if (
      error.name === "MongooseError" ||
      error.message.includes("timed out") ||
      error.message.includes("buffering timed out")
    ) {
      return res.status(503).json({
        success: false,
        error: {
          code: "parcel/service-unavailable",
          message: "Database service temporarily unavailable. Please try again.",
        },
      });
    }

    return res.status(500).json({
      success: false,
      error: {
        code: "parcel/internal-error",
        message: "An unexpected error occurred while fetching parcels.",
      },
    });
  }
};

const getParcelById = async (req, res) => {
  try {
    const { id: parcelId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(parcelId)) {
      return res.status(404).json({
        success: false,
        error: {
          code: "parcel/not-found",
          message: "Parcel not found.",
        },
      });
    }

    const parcel = await Parcel.findById(parcelId)
      .populate({
        path: "senderId",
        select: "name phoneNumber -_id",
      })
      .populate({
        path: "receiverId",
        select: "name phoneNumber -_id",
      })
      .populate({
        path: "assignedRiderId",
        select: "name phoneNumber -_id",
      })
      .select("-__v")
      .lean();

    if (!parcel) {
      return res.status(404).json({
        success: false,
        error: {
          code: "parcel/not-found",
          message: "Parcel not found.",
        },
      });
    }

    if (!hasParcelAccess(parcel, req.user)) {
      return res.status(404).json({
        success: false,
        error: {
          code: "parcel/not-found",
          message: "Parcel not found.",
        },
      });
    }

    return res.status(200).json({
      success: true,
      data: parcel,
    });
  } catch (error) {
    console.error("[parcelController.getParcelById] Error:", error.message);

    if (
      error.name === "MongooseError" ||
      error.message.includes("timed out") ||
      error.message.includes("buffering timed out")
    ) {
      return res.status(503).json({
        success: false,
        error: {
          code: "parcel/service-unavailable",
          message: "Database service temporarily unavailable. Please try again.",
        },
      });
    }

    return res.status(500).json({
      success: false,
      error: {
        code: "parcel/internal-error",
        message: "An unexpected error occurred while fetching the parcel.",
      },
    });
  }
};

module.exports = {
  getAllParcels,
  getParcelById,
};
