const rateLimit = require('express-rate-limit');

const rateLimiterMiddleware = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  standardHeaders: true,
  legacyHeaders: false,
  message: 'Too many requests from this IP, please try again later.',
});

module.exports = rateLimiterMiddleware;
