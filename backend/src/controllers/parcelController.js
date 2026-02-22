const Parcel = require("../models/Parcel");

const getAllParcels = async (req, res) => {
  try {
    const userId = req.user._id;

    const parcels = await Parcel.find({
      $or: [{ senderId: userId }, { receiverId: userId }],
    })
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
      .sort({ createdAt: -1 })
      .lean();

    return res.status(200).json({
      success: true,
      count: parcels.length,
      data: parcels,
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

module.exports = {
  getAllParcels,
};
