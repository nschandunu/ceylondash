const express = require("express");
const router = express.Router();

const { protect } = require("../middleware/authMiddleware");
const { getAllParcels } = require("../controllers/parcelController");

/**
 * @route   GET /api/parcels
 * @desc    Get all parcels for authenticated user
 * @access  Private
 *
 * Middleware chain:
 * 1. protect - Validates Firebase token and attaches req.user
 * 2. getAllParcels - Returns parcels where user is sender or receiver
 */
router.get("/", protect, getAllParcels);

module.exports = router;
