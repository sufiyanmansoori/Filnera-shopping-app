module.exports = {
  database: require('./database.config'),
  redis: require('./redis.config'),
  env: require('./environment.config'),
  logger: require('./logger.config'),
  aws: require('./aws.config'),
  payment: require('./payment.config'),
  email: require('./email.config'),
  kafka: require('./kafka.config'),
};
