const Joi = require('joi');

function validateBody(schema, payload) {
  return schema.validate(payload);
}

module.exports = { validateBody };
