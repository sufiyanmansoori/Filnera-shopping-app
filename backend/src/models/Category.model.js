const mongoose = require('mongoose');
const { CategorySchema } = require('./schemas');
module.exports = mongoose.model('Category', CategorySchema);
