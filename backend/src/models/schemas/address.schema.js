const mongoose = require('mongoose');
module.exports = new mongoose.Schema({ userId: String, city: String, state: String }, { timestamps: true });
