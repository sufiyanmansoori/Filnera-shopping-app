const { successResponse } = require('../../utils/response');
module.exports = { getProfile: async (req, res) => successResponse(res, 200, { user: req.user || {} }, 'Profile retrieved'), updateProfile: async (req, res) => successResponse(res, 200, { updated: true }, 'Profile updated') };
