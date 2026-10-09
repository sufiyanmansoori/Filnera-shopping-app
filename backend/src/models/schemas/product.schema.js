const mongoose = require('mongoose');
module.exports = new mongoose.Schema({ name: String, price: Number, stock: Number }, { timestamps: true });
