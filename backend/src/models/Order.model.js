const mongoose = require('mongoose');
const { OrderSchema } = require('./schemas');
module.exports = mongoose.model('Order', OrderSchema);
