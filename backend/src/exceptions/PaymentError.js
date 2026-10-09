const AppError = require('./AppError');
module.exports = class PaymentError extends AppError { constructor(message = 'Payment failed') { super(message, 402); this.name = 'PaymentError'; } };
