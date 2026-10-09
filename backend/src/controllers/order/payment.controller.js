module.exports = {
  createCheckout: async (req, res) => res.json({ success: true, message: 'Checkout created' }),
  verifyPayment: async (req, res) => res.json({ success: true }),
  processPayment: async (req, res) => res.json({ success: true }),
};
