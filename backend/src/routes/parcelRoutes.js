const express = require("express");
const router = express.Router();

const { protect } = require("../middleware/authMiddleware");
const { getAllParcels, getParcelById } = require("../controllers/parcelController");

router.get("/", protect, getAllParcels);

router.get("/:id", protect, getParcelById);

module.exports = router;
