const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');

dotenv.config();

// Database config import (Comment out if DB connection fails on Vercel free tier)
// const connectDatabase = require('./src/config/database.config');

const app = express();
const PORT = process.env.PORT || 5000;

// Connect to database only if not in Vercel serverless env (optional optimization)
if (process.env.NODE_ENV !== 'production') {
    // connectDatabase(); 
}

// CORS enable karein
app.use(cors({
  origin: '*', // Production mein apni frontend URL dalein
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Middleware
app.use(express.json());

// ✅ ROOT ROUTE - "Cannot GET /" fix karne ke liye
app.get('/', (req, res) => {
  res.json({ 
    message: "Filnera Backend is Live! 🚀",
    status: "Active",
    docs: "Visit /api/home for data"
  });
});

// ⚠️ TEST ROUTES
app.get('/api', (req, res) => {
  res.json({ message: 'API Working', status: 'OK' });
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.get('/api/home', (req, res) => {
  res.json({
    banners: [
      { id: '1', title: 'Fresh deals for the new season', imageUrl: 'https://via.placeholder.com/800x400/FF6B35/FFFFFF?text=Fresh+Deals' }
    ],
    categories: [
      { id: '1', name: 'Wearables', imageUrl: 'https://via.placeholder.com/100' },
      { id: '2', name: 'Audio', imageUrl: 'https://via.placeholder.com/100' },
      { id: '3', name: 'Home', imageUrl: 'https://via.placeholder.com/100' },
      { id: '4', name: 'Travel', imageUrl: 'https://via.placeholder.com/100' },
      { id: '5', name: 'Photography', imageUrl: 'https://via.placeholder.com/100' },
      { id: '6', name: 'Wellness', imageUrl: 'https://via.placeholder.com/100' }
    ],
    deals: [
      { id: '1', productId: 'p1', productName: 'Smart Watch Pro', productImage: 'https://via.placeholder.com/200', originalPrice: 5999, dealPrice: 3999, discountPercent: 33 },
      { id: '2', productId: 'p2', productName: 'Wireless Earbuds', productImage: 'https://via.placeholder.com/200', originalPrice: 2999, dealPrice: 1999, discountPercent: 33 },
      { id: '3', productId: 'p3', productName: 'Bluetooth Speaker', productImage: 'https://via.placeholder.com/200', originalPrice: 1999, dealPrice: 1299, discountPercent: 35 }
    ],
    featuredProducts: [
      { id: 'p1', name: 'Smart Watch Pro', price: 3999, originalPrice: 5999, imageUrl: 'https://via.placeholder.com/200', rating: 4.5, reviewCount: 128, isInStock: true },
      { id: 'p2', name: 'Wireless Earbuds', price: 1999, originalPrice: 2999, imageUrl: 'https://via.placeholder.com/200', rating: 4.3, reviewCount: 89, isInStock: true },
      { id: 'p3', name: 'Bluetooth Speaker', price: 1299, originalPrice: 1999, imageUrl: 'https://via.placeholder.com/200', rating: 4.7, reviewCount: 256, isInStock: true },
      { id: 'p4', name: 'Fitness Tracker', price: 2499, originalPrice: 3499, imageUrl: 'https://via.placeholder.com/200', rating: 4.2, reviewCount: 67, isInStock: true }
    ]
  });
});

// ✅ VERCEL COMPATIBLE EXPORT
// Yeh line Vercel ko batati hai ki request handle karne ke liye 'app' use karein
module.exports = app;

// ✅ LOCAL DEVELOPMENT KE LIYE SERVER START
// Sirf tab run karega jab file directly node se chalayi jaye, Vercel par ignore hogi
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`📡 API available at http://localhost:${PORT}/api`);
     console.log(`🏠 Home API: http://localhost:${PORT}/api/home`);
  });
}