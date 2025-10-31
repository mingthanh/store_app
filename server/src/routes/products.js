import { Router } from 'express';
import Product from '../models/Product.js';
import { authRequired, adminOnly } from '../middleware/auth.js';

const router = Router();

// List products
router.get('/', async (req, res) => {
  const { category, limit = 50 } = req.query;
  const q = {};
  if (category) q.category = category;
  const items = await Product.find(q).sort({ createdAt: -1 }).limit(Number(limit));
  res.json(items);
});

// Create product
router.post('/', authRequired, adminOnly, async (req, res) => {
  try {
    const created = await Product.create(req.body);
    res.status(201).json(created);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// Update product
router.put('/:id', authRequired, adminOnly, async (req, res) => {
  try {
    const updated = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(updated);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// Delete product
router.delete('/:id', authRequired, adminOnly, async (req, res) => {
  try {
    await Product.findByIdAndDelete(req.params.id);
    res.json({ ok: true });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

export default router;
