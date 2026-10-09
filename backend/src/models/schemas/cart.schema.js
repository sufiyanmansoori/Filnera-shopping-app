const mongoose = require('mongoose');
module.exports = new mongoose.Schema({ userId: String, items: [Object] }, { timestamps: true });
