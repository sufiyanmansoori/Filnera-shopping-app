const { signToken } = require('../../utils/jwt');
module.exports = { generateAccessToken: (user) => signToken({ sub: user.id, role: user.role || 'customer' }), generateRefreshToken: (user) => signToken({ sub: user.id, type: 'refresh' }, process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET, process.env.JWT_REFRESH_EXPIRES_IN || '30d') };
