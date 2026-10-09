const { successResponse } = require('../../utils/response');
const { products } = require('../../data/marketplaceCatalog');

function getProducts(req, res) {
  const query = String(req.query.search || req.query.q || '').trim().toLowerCase();
  const category = String(req.query.category || '').trim().toLowerCase();
  const filtered = products.filter((product) => (
    (!query || `${product.name} ${product.category}`.toLowerCase().includes(query))
    && (!category || product.category.toLowerCase() === category)
  ));
  return successResponse(res, 200, { items: filtered, total: filtered.length }, 'Products fetched');
}

function getProductById(req, res) {
  const product = products.find((item) => item.id === req.params.id);
  if (!product) return successResponse(res, 404, null, 'Product not found');
  return successResponse(res, 200, product, 'Product details fetched');
}

module.exports = { getProducts, getProductById };
