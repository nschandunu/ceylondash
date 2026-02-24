const express = require("express");
const router = express.Router();

const { protect, restrictTo } = require("../middleware/authMiddleware");
const { getAllParcels, getParcelById, createParcel, assignRider, updateStatus } = require("../controllers/parcelController");
const { generateHandoverToken } = require("../controllers/verificationController");

router.get("/", protect, getAllParcels);

router.post("/", protect, createParcel);

router.get("/:id", protect, getParcelById);

router.patch("/:id/assign", protect, restrictTo("rider", "admin"), assignRider);

router.patch("/:id/status", protect, updateStatus);

router.post("/:id/generate-token", protect, generateHandoverToken);

module.exports = router;
