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
// Removed VNPay routes; using VietQR QuickLink instead
import paymentsQrRouter from './routes/payments_qr.js';
import trackingRouter from './routes/tracking.js';

dotenv.config(); // Đọc biến môi trường từ .env nếu có

const app = express();
app.use(cors()); // Cho phép cross-origin từ client Flutter/web
app.use(express.json()); // Parse JSON body

// Diagnostics for unexpected exits/signals
process.on('exit', (code) => console.log(`[Process] exit with code ${code}`));
process.on('SIGINT', () => console.log('[Process] SIGINT received'));
process.on('SIGTERM', () => console.log('[Process] SIGTERM received'));
process.on('uncaughtException', (err) => console.error('[Process] uncaughtException', err));
process.on('unhandledRejection', (reason) => console.error('[Process] unhandledRejection', reason));

// Static hosting for uploaded files
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const uploadsDir = path.resolve(__dirname, '../../uploads');
app.use('/uploads', express.static(uploadsDir)); // Phục vụ file tĩnh đã upload

const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/store_app';

async function start() {
  // Health first, then mount routes, then start server; connect to Mongo in background.
  app.get('/health', (_req, res) => {
    // mongoose.connection.readyState: 0 = disconnected, 1 = connected, 2 = connecting, 3 = disconnecting
    res.json({ ok: true, dbState: mongoose.connection.readyState });
  });
  app.get('/', (_req, res) => res.type('text').send('Store API running. Try /health or /api/products'));

  app.use('/api/auth', authRouter);
  app.use('/api/products', productsRouter);
  app.use('/api/admin', adminRouter);
  app.use('/api/orders', ordersRouter);
  app.use('/api/users', usersRouter);
  app.use('/api/uploads', uploadsRouter);
  app.use('/api/payments/qr', paymentsQrRouter);
  app.use('/api/tracking', trackingRouter);

  app.listen(PORT, () => console.log(`[Server] running on http://localhost:${PORT}`));

  // Try to connect to MongoDB but do not block the server if it fails
  try {
    const dbName = process.env.MONGO_DB && process.env.MONGO_DB.trim().length > 0
      ? process.env.MONGO_DB
      : undefined;
    await mongoose.connect(MONGO_URI, { dbName });
    console.log('[MongoDB] connected');
  } catch (err) {
    console.error('[MongoDB] connection failed:', err?.message || err);
    // Do not exit; API parts that don't require DB (health, payments ping, etc.) can still operate
  }
}

start();
