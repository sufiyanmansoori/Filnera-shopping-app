function queueMessage(queueName, payload) {
  return { queueName, payload, queued: true };
}

module.exports = { queueMessage };
