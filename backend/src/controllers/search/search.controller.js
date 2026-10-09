const { products } = require('../../data/marketplaceCatalog');
const { successResponse } = require('../../utils/response');

function searchByQuery(req, res) {
  const query = String(req.query.q || req.query.search || '').trim().toLowerCase();
  const items = products.filter((product) => !query || `${product.name} ${product.category}`.toLowerCase().includes(query));
  return successResponse(res, 200, { items, total: items.length, query }, 'Search completed');
}

module.exports = { searchByQuery };
