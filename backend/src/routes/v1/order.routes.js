const express = require('express');
const { orderController } = require('../../controllers');
const { authMiddleware } = require('../../middleware');
const router = express.Router();
router.get('/', authMiddleware, orderController.getOrders);
router.post('/', authMiddleware, orderController.createOrder);
module.exports = router;
