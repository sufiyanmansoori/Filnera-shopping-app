const AppError = require('./AppError');
module.exports = class NotFoundError extends AppError { constructor(message = 'Resource not found') { super(message, 404); this.name = 'NotFoundError'; } };
