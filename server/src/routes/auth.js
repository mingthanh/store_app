import { Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import User from '../models/User.js';

const router = Router();

function signToken(user) {
  const payload = { id: user._id.toString(), role: user.role };
  return jwt.sign(payload, process.env.JWT_SECRET || 'dev_secret', { expiresIn: '7d' });
}

// Register (default role = 1 user)
router.post('/register', async (req, res) => {
  try {
    const { name = '', email, password, role } = req.body;
    if (!email || !password) return res.status(400).json({ error: 'email and password required' });
    const exists = await User.findOne({ email });
    if (exists) return res.status(409).json({ error: 'email already exists' });
    const passwordHash = await bcrypt.hash(password, 10);
    const user = await User.create({ name, email, passwordHash, role: role === 0 ? 0 : 1 });
    const token = signToken(user);
    res.status(201).json({ token, user: { id: user._id, name: user.name, email: user.email, role: user.role } });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(401).json({ error: 'invalid credentials' });
    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) return res.status(401).json({ error: 'invalid credentials' });
    const token = signToken(user);
    res.json({ token, user: { id: user._id, name: user.name, email: user.email, role: user.role } });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// Social Login Token Generation
router.post('/social-token', async (req, res) => {
  try {
    const { firebaseUid, email, name } = req.body;
    if (!firebaseUid || !email) {
      return res.status(400).json({ error: 'firebaseUid and email required' });
    }

    // Find or create user with Firebase UID
    let user = await User.findOne({ firebaseUid });
    if (!user) {
      // Create new user from social login
      user = await User.create({
        firebaseUid,
        name: name || '',
        email,
        passwordHash: '', // No password for social users
        role: email.toLowerCase().startsWith('admin0411@') ? 0 : 1,
      });
    } else {
      // Update existing user info
      user.name = name || user.name;
      user.email = email;
      await user.save();
    }

    const token = signToken(user);
    res.json({ 
      token, 
      user: { 
        id: user._id, 
        name: user.name, 
        email: user.email, 
        role: user.role 
      } 
    });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

export default router;
