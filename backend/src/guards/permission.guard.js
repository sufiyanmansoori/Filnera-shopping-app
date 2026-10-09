function permissionGuard(permission) { return (req, res, next) => next(); }
module.exports = permissionGuard;
