const mongoose = require('mongoose');
module.exports = new mongoose.Schema({ name: String, value: Number }, { timestamps: true });
