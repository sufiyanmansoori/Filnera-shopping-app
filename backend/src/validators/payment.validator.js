const Joi = require('joi');
module.exports = Joi.object({ amount: Joi.number().positive().required() });
