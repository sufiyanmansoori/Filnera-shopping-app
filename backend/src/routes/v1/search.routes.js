const express = require('express');
const { searchController, suggestionsController } = require('../../controllers');
const router = express.Router();
router.get('/', searchController.searchByQuery);
router.get('/suggestions', suggestionsController.getSuggestions);
module.exports = router;
