const redis = require('redis');
const logger = require('../utils/logger');

let client;

function createRedisClient() {
  const url = process.env.REDIS_URL || 'redis://localhost:6379';

  client = redis.createClient({ url });
  client.on('error', (err) => logger.error('Redis error', err));
  client.on('connect', () => logger.info('Redis connected successfully'));

  return client;
}

async function connectRedis() {
  if (!client) {
    client = createRedisClient();
  }

  await client.connect();
  return client;
}

module.exports = { createRedisClient, connectRedis };
