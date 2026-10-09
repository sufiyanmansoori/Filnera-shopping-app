const Joi = require('joi');
module.exports = Joi.object({ productId: Joi.string().required(), quantity: Joi.number().min(1).required() });
