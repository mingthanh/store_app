import express from 'express'; // Web framework
import cors from 'cors';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import productsRouter from './routes/products.js';
import authRouter from './routes/auth.js';
import adminRouter from './routes/admin.js';
import ordersRouter from './routes/orders.js';
import usersRouter from './routes/users.js';
import uploadsRouter from './routes/uploads.js';

dotenv.config(); // Đọc biến môi trường từ .env nếu có

const app = express();
app.use(cors()); // Cho phép cross-origin từ client Flutter/web
app.use(express.json()); // Parse JSON body

// Static hosting for uploaded files
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const uploadsDir = path.resolve(__dirname, '../../uploads');
app.use('/uploads', express.static(uploadsDir)); // Phục vụ file tĩnh đã upload

const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/store_app';

async function start() {
  try {
    // If MONGO_DB is provided, it overrides the DB in the URI; if not, URI's DB is used
    const dbName = process.env.MONGO_DB && process.env.MONGO_DB.trim().length > 0
      ? process.env.MONGO_DB
      : undefined;
  await mongoose.connect(MONGO_URI, { dbName }); // Kết nối MongoDB
    console.log('[MongoDB] connected');

  app.get('/health', (_req, res) => res.json({ ok: true })); // healthcheck đơn giản
  app.get('/', (_req, res) => res.type('text').send('Store API running. Try /health or /api/products'));

  app.use('/api/auth', authRouter);
  app.use('/api/products', productsRouter);
  app.use('/api/admin', adminRouter);
  app.use('/api/orders', ordersRouter);
  app.use('/api/users', usersRouter);
  app.use('/api/uploads', uploadsRouter);

    app.listen(PORT, () => console.log(`[Server] running on http://localhost:${PORT}`));
  } catch (err) {
    console.error('[Server] failed to start', err);
    process.exit(1);
  }
}

start();
