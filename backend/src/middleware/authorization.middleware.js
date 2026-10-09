const { AuthorizationError } = require('../exceptions');

function authorizationMiddleware(allowedRoles = []) {
  return (req, res, next) => {
    if (!req.user) return next(new AuthorizationError('Access denied'));
    if (allowedRoles.length && !allowedRoles.includes(req.user.role)) {
      return next(new AuthorizationError('You do not have permission to access this resource'));
    }
    next();
  };
}

module.exports = authorizationMiddleware;
