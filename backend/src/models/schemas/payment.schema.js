const mongoose = require('mongoose');
module.exports = new mongoose.Schema({ orderId: String, amount: Number, status: String }, { timestamps: true });
