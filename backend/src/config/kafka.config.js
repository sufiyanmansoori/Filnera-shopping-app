module.exports = {
  clientId: process.env.KAFKA_CLIENT_ID || 'manarashop-client',
  brokers: (process.env.KAFKA_BROKERS || 'localhost:9092').split(','),
};
