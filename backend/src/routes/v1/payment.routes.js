const express = require('express');
const { paymentController } = require('../../controllers');
const router = express.Router();
router.post('/checkout', paymentController.createCheckout);
module.exports = router;
