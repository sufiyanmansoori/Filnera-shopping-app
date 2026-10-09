const errorMiddleware = require('./errorHandler.middleware');

module.exports = {
  authMiddleware: require('./auth.middleware'),
  authorizationMiddleware: require('./authorization.middleware'),
  errorHandler: errorMiddleware.errorHandler,
  validationMiddleware: require('./validation.middleware'),
  corsMiddleware: require('./cors.middleware'),
  rateLimiterMiddleware: require('./rateLimiter.middleware'),
  requestLogger: require('./requestLogger.middleware'),
  compressionMiddleware: require('./compression.middleware'),
  bodyParserMiddleware: require('./bodyParser.middleware'),
  securityHeaders: require('./securityHeaders.middleware'),
  trustProxy: require('./trustProxy.middleware'),
  notFoundHandler: errorMiddleware.notFoundHandler,
};
