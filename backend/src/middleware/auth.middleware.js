const { verifyToken } = require('../utils/jwt');
const { AuthenticationError } = require('../exceptions');

function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;

  if (!token) {
    return next(new AuthenticationError('Access token is missing'));
  }

  try {
    const decoded = verifyToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    next(new AuthenticationError('Invalid or expired access token'));
  }
}

module.exports = authMiddleware;
