import { Router } from 'express';
import User from '../models/User.js';
import { authRequired, adminOnly } from '../middleware/auth.js';

const router = Router();

// List users (admin)
router.get('/', authRequired, adminOnly, async (_req, res) => {
  try {
    const users = await User.find({}, { passwordHash: 0 }).sort({ createdAt: -1 });
    res.json(users);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// Get current user profile
router.get('/me', authRequired, async (req, res) => {
  try {
    const user = await User.findById(req.user.id, { passwordHash: 0 });
    if (!user) return res.status(404).json({ error: 'user not found' });
    res.json(user);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// Update current user profile
router.put('/me', authRequired, async (req, res) => {
  try {
    const { name, phone, avatarUrl } = req.body;
    const update = {};
    if (typeof name === 'string') update.name = name;
    if (typeof phone === 'string') update.phone = phone;
    if (typeof avatarUrl === 'string') update.avatarUrl = avatarUrl;
    const user = await User.findByIdAndUpdate(req.user.id, update, { new: true, projection: { passwordHash: 0 } });
    if (!user) return res.status(404).json({ error: 'user not found' });
    res.json(user);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// Update user (admin) - must be after '/me' so it doesn't catch '/me' as ':id'
router.put('/:id', authRequired, adminOnly, async (req, res) => {
  try {
    const { id } = req.params;
    const { name, role, phone, avatarUrl } = req.body;
    const update = {};
    if (typeof name === 'string') update.name = name;
    if (role === 0 || role === 1) update.role = role;
    if (typeof phone === 'string') update.phone = phone;
    if (typeof avatarUrl === 'string') update.avatarUrl = avatarUrl;
    const user = await User.findByIdAndUpdate(id, update, { new: true, projection: { passwordHash: 0 } });
    if (!user) return res.status(404).json({ error: 'user not found' });
    res.json(user);
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

export default router;
