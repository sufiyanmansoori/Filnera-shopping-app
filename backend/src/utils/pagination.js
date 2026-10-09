function paginate(page = 1, limit = 10, total = 0) {
  const currentPage = Number(page) > 0 ? Number(page) : 1;
  const perPage = Number(limit) > 0 ? Number(limit) : 10;

  return {
    page: currentPage,
    limit: perPage,
    totalPages: Math.ceil(total / perPage) || 1,
    total,
  };
}

module.exports = { paginate };
