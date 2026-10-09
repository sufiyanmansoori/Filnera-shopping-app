const mongoose = require('mongoose');
module.exports = new mongoose.Schema({ code: String, discount: Number }, { timestamps: true });
