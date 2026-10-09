const mongoose = require('mongoose');
const { AddressSchema } = require('./schemas');
module.exports = mongoose.model('Address', AddressSchema);
