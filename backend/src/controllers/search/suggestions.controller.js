const { products, categories } = require('../../data/marketplaceCatalog');
const { successResponse } = require('../../utils/response');

function getSuggestions(req, res) {
  const query = String(req.query.q || '').trim().toLowerCase();
  const productSuggestions = products.filter((product) => !query || product.name.toLowerCase().includes(query)).map((product) => product.name);
  const categorySuggestions = categories.filter((category) => !query || category.toLowerCase().includes(query));
  return successResponse(res, 200, { products: productSuggestions, categories: categorySuggestions, trending: ['iPhone', 'Samsung', 'OnePlus'] }, 'Suggestions fetched');
}

module.exports = { getSuggestions };
