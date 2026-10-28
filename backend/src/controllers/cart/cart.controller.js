const { successResponse } = require('../../utils/response');
const { asyncHandler } = require('../../utils/helpers');
const cartService = require('../../services/cart/cart.service');

const cartController = {
  getCart: asyncHandler(async (req, res) => {
    const cart = await cartService.getCart(req.user.sub);
    return successResponse(res, 200, cart, 'Cart fetched');
  }),
  addItem: asyncHandler(async (req, res) => {
    const cart = await cartService.addItem(req.user.sub, req.body);
    return successResponse(res, 200, cart, 'Item added to cart');
  }),
  updateItem: asyncHandler(async (req, res) => {
    const cart = await cartService.updateItem(
      req.user.sub,
      req.params.productId,
      req.body.quantity,
    );
    return successResponse(res, 200, cart, 'Cart item updated');
  }),
  removeItem: asyncHandler(async (req, res) => {
    const cart = await cartService.removeItem(req.user.sub, req.params.productId);
    return successResponse(res, 200, cart, 'Cart item removed');
  }),
};

module.exports = cartController;
