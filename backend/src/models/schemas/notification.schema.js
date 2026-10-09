const mongoose = require('mongoose');
module.exports = new mongoose.Schema({ userId: String, message: String }, { timestamps: true });
