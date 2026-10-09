const express = require('express');
const { cartController } = require('../../controllers');
const { authMiddleware } = require('../../middleware');
const router = express.Router();
router.get('/', authMiddleware, cartController.getCart);
router.post('/items', authMiddleware, cartController.addItem);
module.exports = router;
