const express = require("express");
const router = express.Router();

const { protect } = require("../middleware/authMiddleware");
const { getAllParcels, getParcelById } = require("../controllers/parcelController");
const { generateHandoverToken } = require("../controllers/verificationController");

router.get("/", protect, getAllParcels);

router.get("/:id", protect, getParcelById);

router.post("/:id/generate-token", protect, generateHandoverToken);

module.exports = router;
