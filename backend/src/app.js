const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const routes = require('./routes/v1');
const { errorHandler, notFoundHandler, requestLogger, trustProxy, securityHeaders } = require('./middleware');

const app = express();

app.use(trustProxy());
const allowedOrigins = (process.env.CLIENT_URL || '*')
	.split(',')
	.map((origin) => origin.trim());
app.use(cors({
	origin(origin, callback) {
		const isLocalDevelopmentOrigin = process.env.NODE_ENV !== 'production'
			&& origin
			&& /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);
		callback(
			null,
			!origin || allowedOrigins.includes('*') || allowedOrigins.includes(origin) || isLocalDevelopmentOrigin,
		);
	},
	credentials: true,
}));
app.use(helmet());
app.use(compression());
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));
app.use(requestLogger);
app.use(securityHeaders);
app.get('/', (req, res) => {
  res.json({ name: 'Filnera API', status: 'ok', api: '/api/v1' });
});
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
app.use('/api/v1', routes);
app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
