const mongoose = require('mongoose');
const { CouponSchema } = require('./schemas');
module.exports = mongoose.model('Coupon', CouponSchema);
