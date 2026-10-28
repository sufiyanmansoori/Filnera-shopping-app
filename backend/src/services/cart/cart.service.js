const Cart = require('../../models/Cart.model');
const { products } = require('../../data/marketplaceCatalog');
const AppError = require('../../exceptions/AppError');

const MAX_ITEM_QUANTITY = 99;

function serializeCart(cart) {
  return {
    items: cart.items.map((item) => ({
      id: item.productId,
      productId: item.productId,
      productName: item.productName,
      productImage: item.productImage,
      price: item.unitPrice,
      quantity: item.quantity,
      variant: item.variant,
      seller: item.seller,
    })),
    couponCode: '',
    discount: 0,
    deliveryFee: 0,
  };
}

async function getCart(userId) {
  const cart = await Cart.findOne({ userId });
  return serializeCart(cart || { items: [] });
}

async function addItem(userId, { productId, quantity = 1 }) {
  if (typeof productId !== 'string' || !productId.trim()) {
    throw new AppError('A valid productId is required', 400);
  }
  if (!Number.isInteger(quantity) || quantity < 1 || quantity > MAX_ITEM_QUANTITY) {
    throw new AppError(`Quantity must be between 1 and ${MAX_ITEM_QUANTITY}`, 400);
  }

  const product = products.find((item) => item.id === productId);
  if (!product) throw new AppError('Product not found', 404);

  const cart = await Cart.findOne({ userId }) || new Cart({ userId, items: [] });
  const current = cart.items.find((item) => item.productId === productId);
  const newQuantity = (current ? current.quantity : 0) + quantity;
  if (newQuantity > product.stock) {
    throw new AppError('Requested quantity exceeds available stock', 409);
  }

  if (current) {
    current.quantity = newQuantity;
    current.unitPrice = product.price;
    current.productName = product.name;
    current.productImage = product.imageUrl;
  } else {
    cart.items.push({
      productId: product.id,
      productName: product.name,
      productImage: product.imageUrl,
      unitPrice: product.price,
      quantity,
      variant: 'Default',
      seller: 'Filnera',
    });
  }

  await cart.save();
  return serializeCart(cart);
}

async function updateItem(userId, productId, quantity) {
  if (!Number.isInteger(quantity) || quantity < 1 || quantity > MAX_ITEM_QUANTITY) {
    throw new AppError(`Quantity must be between 1 and ${MAX_ITEM_QUANTITY}`, 400);
  }
  const product = products.find((item) => item.id === productId);
  if (!product) throw new AppError('Product not found', 404);
  if (quantity > product.stock) {
    throw new AppError('Requested quantity exceeds available stock', 409);
  }

  const cart = await Cart.findOne({ userId });
  if (!cart || !cart.items.some((item) => item.productId === productId)) {
    throw new AppError('Cart item not found', 404);
  }
  const item = cart.items.find((entry) => entry.productId === productId);
  item.quantity = quantity;
  item.unitPrice = product.price;
  await cart.save();
  return serializeCart(cart);
}

async function removeItem(userId, productId) {
  const cart = await Cart.findOne({ userId });
  if (!cart) return serializeCart({ items: [] });
  cart.items = cart.items.filter((item) => item.productId !== productId);
  await cart.save();
  return serializeCart(cart);
}

module.exports = { getCart, addItem, updateItem, removeItem };
