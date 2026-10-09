const redis = require('redis');

function cacheKey(prefix, value) {
  return `${prefix}:${value}`;
}

module.exports = { cacheKey };
