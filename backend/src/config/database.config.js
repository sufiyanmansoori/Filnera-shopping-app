// backend/src/config/database.config.js

const mongoose = require('mongoose');

const connectDatabase = async () => {
  try {
    const uri = process.env.MONGO_URI;

    if (!uri) {
      throw new Error('❌ MONGO_URI is not defined in .env file');
    }

    await mongoose.connect(uri);
    console.log('✅ MongoDB Connected Successfully');
  } catch (error) {
    console.error('❌ MongoDB Connection Error:', error.message);
    process.exit(1);
  }
};

// ⚠️ YE LINE ZAROOR HONI CHAHIYE
module.exports = connectDatabase;