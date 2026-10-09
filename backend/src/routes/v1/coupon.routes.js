const express = require('express');
const { couponController } = require('../../controllers');
const router = express.Router();
router.get('/', couponController.getCoupons);
module.exports = router;
