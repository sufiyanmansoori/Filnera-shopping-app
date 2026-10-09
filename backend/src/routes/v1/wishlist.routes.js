const express = require('express');
const { wishlistController } = require('../../controllers');
const { authMiddleware } = require('../../middleware');
const router = express.Router();
router.get('/', authMiddleware, wishlistController.getWishlist);
module.exports = router;
