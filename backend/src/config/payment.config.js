module.exports = {
  stripe: { secretKey: process.env.STRIPE_SECRET_KEY || '' },
  razorpay: { keyId: process.env.RAZORPAY_KEY_ID || '', keySecret: process.env.RAZORPAY_KEY_SECRET || '' },
};
