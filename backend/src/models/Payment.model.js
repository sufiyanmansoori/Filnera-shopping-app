const mongoose = require('mongoose');
const { PaymentSchema } = require('./schemas');
module.exports = mongoose.model('Payment', PaymentSchema);
