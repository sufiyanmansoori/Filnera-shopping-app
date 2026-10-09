function buildFilters(query = {}) {
  const filters = { ...query };
  delete filters.page;
  delete filters.limit;
  delete filters.sort;
  return filters;
}

module.exports = { buildFilters };
