const mongoose = require('mongoose');
const { NotificationSchema } = require('./schemas');
module.exports = mongoose.model('Notification', NotificationSchema);
