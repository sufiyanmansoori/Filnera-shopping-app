const mongoose = require('mongoose');
module.exports = new mongoose.Schema({ productId: String, quantity: Number }, { timestamps: true });
