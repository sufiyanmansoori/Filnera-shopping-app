const AppError = require('./AppError');
module.exports = class AuthenticationError extends AppError { constructor(message = 'Authentication failed') { super(message, 401); this.name = 'AuthenticationError'; } };
