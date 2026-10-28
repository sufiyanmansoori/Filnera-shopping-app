const express = require('express');
const { cartController } = require('../../controllers');
const { authMiddleware } = require('../../middleware');
const router = express.Router();
router.get('/', authMiddleware, cartController.getCart);
router.post('/items', authMiddleware, cartController.addItem);
router.put('/items/:productId', authMiddleware, cartController.updateItem);
router.delete('/items/:productId', authMiddleware, cartController.removeItem);
module.exports = router;
