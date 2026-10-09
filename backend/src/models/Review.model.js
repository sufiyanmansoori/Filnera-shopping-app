const mongoose = require('mongoose');
const { ReviewSchema } = require('./schemas');
module.exports = mongoose.model('Review', ReviewSchema);
