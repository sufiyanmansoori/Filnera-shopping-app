const mongoose = require('mongoose');
const { AnalyticsSchema } = require('./schemas');
module.exports = mongoose.model('Analytics', AnalyticsSchema);
