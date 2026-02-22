const express = require("express");
const router = express.Router();

const { protect } = require("../middleware/authMiddleware");
const { generateToken, validateToken } = require("../controllers/tokenController");

router.post("/generate/:parcelId", protect, generateToken);
router.post("/validate", protect, validateToken);

module.exports = router;
