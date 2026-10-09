const Joi = require('joi');
module.exports = Joi.object({ q: Joi.string().required() });
