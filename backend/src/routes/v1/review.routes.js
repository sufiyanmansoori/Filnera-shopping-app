const express = require('express');
const { reviewController } = require('../../controllers');
const router = express.Router();
router.get('/:productId', reviewController.getReviews);
router.post('/:productId', reviewController.createReview);
module.exports = router;
