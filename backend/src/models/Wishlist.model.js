const mongoose = require('mongoose');
const { WishlistSchema } = require('./schemas');
module.exports = mongoose.model('Wishlist', WishlistSchema);
