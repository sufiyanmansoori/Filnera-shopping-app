const mongoose = require('mongoose');
module.exports = new mongoose.Schema({ name: String, shopName: String }, { timestamps: true });
