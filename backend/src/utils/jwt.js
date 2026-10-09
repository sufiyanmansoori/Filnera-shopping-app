const jwt = require('jsonwebtoken');

function signToken(payload, secret = process.env.JWT_SECRET, expiresIn = process.env.JWT_EXPIRES_IN || '7d') {
  return jwt.sign(payload, secret, { expiresIn });
}

function verifyToken(token, secret = process.env.JWT_SECRET) {
  return jwt.verify(token, secret);
}

module.exports = { signToken, verifyToken };
