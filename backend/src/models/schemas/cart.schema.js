const mongoose = require('mongoose');

const cartItemSchema = new mongoose.Schema(
  {
    productId: { type: String, required: true },
    productName: { type: String, required: true },
    productImage: { type: String, default: '' },
    unitPrice: { type: Number, required: true, min: 0 },
    quantity: { type: Number, required: true, min: 1 },
    variant: { type: String, default: 'Default' },
    seller: { type: String, default: 'Filnera' },
  },
  { _id: false },
);

module.exports = new mongoose.Schema(
  {
    userId: { type: String, required: true, unique: true, index: true },
    items: { type: [cartItemSchema], default: [] },
  },
  { timestamps: true },
);
