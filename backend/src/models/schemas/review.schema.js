const mongoose = require('mongoose');
module.exports = new mongoose.Schema({ productId: String, userId: String, rating: Number, review: String }, { timestamps: true });
