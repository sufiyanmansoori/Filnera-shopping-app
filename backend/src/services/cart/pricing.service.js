module.exports = { calculateTotal: async (items) => items.reduce((total, item) => total + (item.price || 0), 0) };
