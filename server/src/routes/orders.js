import { Router } from 'express';
import Order from '../models/Order.js';
import { authRequired, adminOnly } from '../middleware/auth.js';

const router = Router();

// Create order (user)
router.post('/', authRequired, async (req, res) => {
  try {
    const userId = req.user.id;
    const { items = [], totalAmount = 0 } = req.body;
    if (!Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ error: 'items required' });
    }
    const order = await Order.create({ userId, items, totalAmount, status: 'pending' });
    res.status(201).json(order);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// Get my orders (user)
router.get('/my', authRequired, async (req, res) => {
  try {
    const userId = req.user.id;
    const orders = await Order.find({ userId }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// List all orders (admin)
router.get('/', authRequired, adminOnly, async (_req, res) => {
  try {
    const orders = await Order.find().sort({ createdAt: -1 });
    res.json(orders);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// Update order status (admin)
router.patch('/:id/status', authRequired, adminOnly, async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const allowed = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
    if (!allowed.includes(status)) {
      return res.status(400).json({ error: 'invalid status' });
    }
    const order = await Order.findByIdAndUpdate(id, { status }, { new: true });
    if (!order) return res.status(404).json({ error: 'order not found' });
    res.json(order);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

export default router;
