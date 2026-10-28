const dotenv = require('dotenv');
const { randomBytes } = require('crypto');

dotenv.config();

const app = require('./src/app');
const connectDatabase = require('./src/config/database.config');
const PORT = process.env.PORT || 5000;

module.exports = app;

if (require.main === module) {
  if (
    !process.env.JWT_SECRET ||
    process.env.JWT_SECRET === 'your_super_secret_key'
  ) {
    if (process.env.NODE_ENV === 'production') {
      throw new Error('Set a unique JWT_SECRET before starting the API');
    }
    process.env.JWT_SECRET = randomBytes(32).toString('hex');
    console.warn(
      'JWT_SECRET is not configured; using an ephemeral development secret.',
    );
  }

  connectDatabase()
    .then(() => {
      app.listen(PORT, () => {
        console.log(`Filnera API listening on port ${PORT}`);
      });
    })
    .catch((error) => {
      console.error('Unable to start Filnera API:', error.message);
      process.exitCode = 1;
    });
}
