const mongoose = require('mongoose');
const { ProductSchema } = require('./schemas');
module.exports = mongoose.model('Product', ProductSchema);
