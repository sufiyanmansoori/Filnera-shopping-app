const AppError = require('./AppError');
module.exports = class ValidationError extends AppError { constructor(message, details) { super(message, 400, details); this.name = 'ValidationError'; } };
