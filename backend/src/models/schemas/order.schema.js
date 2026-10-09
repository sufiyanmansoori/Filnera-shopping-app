const mongoose = require('mongoose');
module.exports = new mongoose.Schema({ userId: String, total: Number, status: String }, { timestamps: true });
