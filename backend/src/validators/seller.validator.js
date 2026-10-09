const Joi = require('joi');
module.exports = Joi.object({ shopName: Joi.string().min(2).required() });
