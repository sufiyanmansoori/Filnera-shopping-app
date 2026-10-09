const mongoose = require('mongoose');
const { SellerSchema } = require('./schemas');
module.exports = mongoose.model('Seller', SellerSchema);
