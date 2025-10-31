# Admin API mode (MongoDB)

This project includes a Node.js backend (server/) using MongoDB for Products/Users/Orders, JWT auth, and an admin dashboard endpoint.

## Backend

1. Create `server/.env` from `.env.example` and set:
```
MONGO_URI=mongodb://127.0.0.1:27017/store_app
PORT=3000
JWT_SECRET=your_secret
```
2. Install deps and seed:
```
npm install
npm run seed
npm run dev
```
3. Test:
- http://localhost:3000/health
- http://localhost:3000/api/products
- POST /api/auth/login { email: "admin@example.com", password: "admin123" }
- GET /api/admin/stats with Bearer token

## Flutter

- Set `ApiService.baseUrl` to the proper host for your environment (localhost / 10.0.2.2 / device IP).
- Use `ProductGrid(useApi: true)` to display products from the API.
- Signin/Signup uses API-based controller; admin users are routed to `/admin` (AdminDashboardApiScreen).
- Only admin can Create/Update/Delete products in the admin screen and see the buttons.
