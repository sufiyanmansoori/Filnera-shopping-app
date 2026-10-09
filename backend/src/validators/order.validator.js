const Joi = require('joi');
module.exports = Joi.object({ total: Joi.number().positive().required() });
