const { products, categories } = require('../data/marketplaceCatalog');
const { successResponse } = require('../utils/response');

function getHome(req, res) {
  return successResponse(res, 200, {
    categories,
    banners: [{ id: 'big-billion-days', title: 'BIG BILLION DAYS', discount: 'UP TO 80% OFF', cta: 'SHOP NOW' }],
    deals: products.map((product) => ({ ...product, discount: Math.round((1 - product.price / product.originalPrice) * 100) })),
    featuredProducts: products.filter((product) => product.isFeatured),
  }, 'Marketplace home fetched');
}

module.exports = { getHome };
