import express from 'express';
import multer from 'multer'; // Xử lý multipart/form-data
import path from 'path';
import fs from 'fs';
import { authRequired, adminOnly } from '../middleware/auth.js';

const router = express.Router();

// Ensure uploads/images directory exists
const uploadsRoot = path.resolve(process.cwd(), 'uploads'); // Thư mục gốc lưu upload
const imagesDir = path.join(uploadsRoot, 'images'); // Lưu ảnh vào /uploads/images
fs.mkdirSync(imagesDir, { recursive: true }); // Đảm bảo tồn tại

const storage = multer.diskStorage({
  destination: function (_req, _file, cb) {
    cb(null, imagesDir);
  },
  filename: function (_req, file, cb) {
    const ext = path.extname(file.originalname) || '.jpg';
    const name = `${Date.now()}-${Math.random().toString(36).slice(2)}${ext}`;
    cb(null, name);
  },
});

const upload = multer({ storage });

// POST /api/uploads/images (admin-only)
router.post('/images', authRequired, adminOnly, upload.single('image'), (req, res) => {
  if (!req.file) return res.status(400).json({ message: 'No file uploaded' });
  const relativePath = `/uploads/images/${req.file.filename}`;
  // Prefer returning relative URL; clients can prepend their own baseUrl
  res.json({ path: relativePath, url: relativePath });
});

export default router;
