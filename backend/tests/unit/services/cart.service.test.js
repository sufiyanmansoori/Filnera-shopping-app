jest.mock('../../../src/models/Cart.model', () => {
  const MockCart = jest.fn(function (data) {
    Object.assign(this, data);
    this.save = jest.fn(async () => this);
  });
  MockCart.findOne = jest.fn();
  return MockCart;
});

const Cart = require('../../../src/models/Cart.model');
const cartService = require('../../../src/services/cart/cart.service');

describe('cart service', () => {
  beforeEach(() => jest.clearAllMocks());

  test('uses server product pricing rather than client-provided price', async () => {
    Cart.findOne.mockResolvedValue(null);

    const cart = await cartService.addItem('user-123', {
      productId: 'p-1',
      quantity: 1,
      price: 0.01,
    });

    expect(Cart.findOne).toHaveBeenCalledWith({ userId: 'user-123' });
    expect(cart.items[0]).toMatchObject({
      productId: 'p-1',
      productName: 'AeroFlex Smartwatch',
      price: 249,
      quantity: 1,
    });
  });

  test('rejects quantities above current product stock', async () => {
    Cart.findOne.mockResolvedValue(null);

    await expect(
      cartService.addItem('user-123', { productId: 'p-1', quantity: 25 }),
    ).rejects.toMatchObject({ statusCode: 409 });
  });

  test('scopes cart lookup to the authenticated user id', async () => {
    Cart.findOne.mockResolvedValue({ items: [] });

    await cartService.getCart('user-456');

    expect(Cart.findOne).toHaveBeenCalledWith({ userId: 'user-456' });
  });
});
