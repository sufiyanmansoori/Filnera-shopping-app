# MANARASHOPPING Backend

Production-ready Node.js e-commerce backend starter.

## Quick start

```bash
cd backend
npm install
# Configure MONGO_URI in .env; local development creates a temporary JWT secret.
npm run dev
```

From the repository root, `npm run dev` starts both the API and Flutter web
app. The API listens on port 5000; Flutter defaults to
`http://127.0.0.1:5000/api/v1`. Set `API_BASE_URL` with
`--dart-define=API_BASE_URL=...` when using another API host. In production,
configure a persistent, unique `JWT_SECRET`.

## Main features
- JWT authentication
- Role-based authorization
- Product catalog APIs
- Cart and order flows
- Payment integration readiness
- Redis caching and logging
- Docker support
