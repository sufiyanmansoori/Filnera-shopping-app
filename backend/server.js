const dotenv = require('dotenv');
dotenv.config();

const app = require('./src/app');
const connectDatabase = require('./src/config/database.config');
const PORT = process.env.PORT || 5000;

connectDatabase();

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`API available at http://localhost:${PORT}/api/v1`);
});