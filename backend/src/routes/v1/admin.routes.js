const express = require('express');
const { adminController } = require('../../controllers');
const { authMiddleware, authorizationMiddleware } = require('../../middleware');
const router = express.Router();
router.get('/dashboard', authMiddleware, authorizationMiddleware(['admin']), adminController.getDashboard);
module.exports = router;
