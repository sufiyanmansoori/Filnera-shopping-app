jest.mock('../../../src/models/User.model', () => ({
  exists: jest.fn(),
  create: jest.fn(),
  findOne: jest.fn(),
}));

const bcrypt = require('bcryptjs');
const User = require('../../../src/models/User.model');
const { verifyToken } = require('../../../src/utils/jwt');
const authService = require('../../../src/services/auth/auth.service');

describe('auth service', () => {
  beforeAll(() => {
    process.env.JWT_SECRET = 'unit-test-secret-that-is-not-for-production';
  });

  beforeEach(() => jest.clearAllMocks());

  test('registers a normalized email and only returns a signed customer session', async () => {
    User.exists.mockResolvedValue(null);
    User.create.mockImplementation(async (data) => ({
      ...data,
      _id: { toString: () => 'user-123' },
    }));

    const session = await authService.register({
      fullName: ' Test Shopper ',
      email: ' SHOPPER@example.com ',
      password: 'secure-password',
      phone: '1234567890',
    });

    expect(session.user).toEqual({
      id: 'user-123',
      email: 'shopper@example.com',
      fullName: 'Test Shopper',
      roles: ['customer'],
    });
    const stored = User.create.mock.calls[0][0];
    expect(stored.password).not.toBe('secure-password');
    expect(await bcrypt.compare('secure-password', stored.password)).toBe(true);
    expect(verifyToken(session.token).sub).toBe('user-123');
  });

  test('rejects duplicate registrations', async () => {
    User.exists.mockResolvedValue({ _id: 'existing' });

    await expect(
      authService.register({
        name: 'Shopper',
        email: 'shopper@example.com',
        password: 'secure-password',
      }),
    ).rejects.toMatchObject({ statusCode: 409 });
    expect(User.create).not.toHaveBeenCalled();
  });

  test('rejects incorrect credentials without disclosing account existence', async () => {
    const password = await bcrypt.hash('correct-password', 4);
    User.findOne.mockReturnValue({
      select: jest.fn().mockResolvedValue({
        _id: { toString: () => 'user-123' },
        email: 'shopper@example.com',
        name: 'Shopper',
        roles: ['customer'],
        password,
      }),
    });

    await expect(
      authService.login({
        email: 'shopper@example.com',
        password: 'incorrect-password',
      }),
    ).rejects.toMatchObject({ statusCode: 401, message: 'Invalid email or password' });
  });
});
