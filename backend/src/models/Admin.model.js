const mongoose = require('mongoose');
const { AdminSchema } = require('./schemas');
module.exports = mongoose.model('Admin', AdminSchema);
