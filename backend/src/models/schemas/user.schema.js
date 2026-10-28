const mongoose = require('mongoose');

module.exports = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true, minlength: 2, maxlength: 100 },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true, index: true },
    password: { type: String, required: true, select: false },
    phone: { type: String, trim: true, default: '' },
    roles: { type: [String], default: ['customer'] },
  },
  { timestamps: true },
);
