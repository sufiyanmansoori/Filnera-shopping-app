function roleGuard(roles = []) { return (req, res, next) => next(); }
module.exports = roleGuard;
