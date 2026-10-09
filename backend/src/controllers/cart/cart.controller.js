module.exports = { getCart: async (req, res) => res.json({ success: true, data: { items: [] } }), addItem: async (req, res) => res.json({ success: true, message: 'Item added to cart' }) };
