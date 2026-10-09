const express = require('express');
const { sellerController } = require('../../controllers');
const { authMiddleware } = require('../../middleware');
const router = express.Router();
router.get('/dashboard', authMiddleware, sellerController.getDashboard);
module.exports = router;
