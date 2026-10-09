const AppError = require('./AppError');
module.exports = class InventoryError extends AppError { constructor(message = 'Inventory validation failed') { super(message, 422); this.name = 'InventoryError'; } };
