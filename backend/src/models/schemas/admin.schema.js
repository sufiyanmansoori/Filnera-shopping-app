const mongoose = require('mongoose');
module.exports = new mongoose.Schema({ name: String, email: String }, { timestamps: true });
