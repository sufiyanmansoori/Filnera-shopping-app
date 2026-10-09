function validateEnv() {
  const required = ['JWT_SECRET', 'MONGO_URI'];
  const missing = required.filter((key) => !process.env[key]);

  if (missing.length > 0) {
    console.warn(`Missing environment variables: ${missing.join(', ')}`);
  }

  return { missing };
}

module.exports = { validateEnv };
