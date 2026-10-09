const mongoose = require('mongoose');
module.exports = new mongoose.Schema({ userId: String, productIds: [String] }, { timestamps: true });
