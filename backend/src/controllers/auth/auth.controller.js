const { successResponse } = require('../../utils/response');
const { asyncHandler } = require('../../utils/helpers');
const authService = require('../../services/auth/auth.service');

const authController = {
  register: asyncHandler(async (req, res) => {
    const session = await authService.register(req.body);
    return successResponse(res, 201, session, 'User registered successfully');
  }),
  login: asyncHandler(async (req, res) => {
    const session = await authService.login(req.body);
    return successResponse(res, 200, session, 'Login successful');
  }),
  logout: asyncHandler(async (req, res) => {
    return successResponse(res, 200, null, 'Logout successful');
  }),
};

module.exports = authController;
