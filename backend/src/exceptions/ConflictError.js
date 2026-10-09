const AppError = require('./AppError');
module.exports = class ConflictError extends AppError { constructor(message = 'Conflict') { super(message, 409); this.name = 'ConflictError'; } };
