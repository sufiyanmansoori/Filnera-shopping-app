const { successResponse } = require('../../utils/response');
const { asyncHandler } = require('../../utils/helpers');

const authController = {
  register: asyncHandler(async (req, res) => {
    return successResponse(res, 201, { registered: true }, 'User registered successfully');
  }),
  login: asyncHandler(async (req, res) => {
    return successResponse(res, 200, { token: 'demo-token' }, 'Login successful');
  }),
  logout: asyncHandler(async (req, res) => {
    return successResponse(res, 200, null, 'Logout successful');
  }),
};

module.exports = authController;
