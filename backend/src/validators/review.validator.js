const Joi = require('joi');
module.exports = Joi.object({ rating: Joi.number().min(1).max(5).required(), review: Joi.string().required() });
