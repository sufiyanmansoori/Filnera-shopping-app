const AppError = require('./AppError');
module.exports = class AuthorizationError extends AppError { constructor(message = 'Forbidden') { super(message, 403); this.name = 'AuthorizationError'; } };
