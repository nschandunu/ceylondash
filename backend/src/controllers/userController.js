const User = require('../models/User');

/**
 * GET /api/users/search?query=
 * Searches users by name or phone number (case-insensitive, limit 5).
 * Returns only public fields: _id, name, phoneNumber, role.
 */
const searchUsers = async (req, res) => {
  try {
    const { query } = req.query;

    if (!query || query.trim().length < 2) {
      return res.status(400).json({
        success: false,
        error: { code: 'INVALID_QUERY', message: 'Search query must be at least 2 characters.' },
      });
    }

    const escaped = query.trim().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const regex = new RegExp(escaped, 'i');

    const users = await User.find({
      $or: [
        { name: regex },
        { phoneNumber: regex },
      ],
      _id: { $ne: req.user._id },
      isActive: true,
    })
      .select('_id name phoneNumber role')
      .limit(5)
      .lean();

    return res.status(200).json({
      success: true,
      data: users,
    });
  } catch (err) {
    console.error('searchUsers error:', err);
    return res.status(500).json({
      success: false,
      error: { code: 'SERVER_ERROR', message: 'Failed to search users.' },
    });
  }
};

module.exports = { searchUsers };
