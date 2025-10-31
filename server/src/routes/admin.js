import { Router } from 'express';
import User from '../models/User.js';
import Product from '../models/Product.js';
import Order from '../models/Order.js';
import { authRequired, adminOnly } from '../middleware/auth.js';

const router = Router();

// All routes here require admin
router.use(authRequired, adminOnly);

router.get('/stats', async (_req, res) => {
  const [users, products, orders, revenueAgg] = await Promise.all([
    User.countDocuments(),
    Product.countDocuments(),
    Order.countDocuments(),
    Order.aggregate([
      { $group: { _id: null, revenue: { $sum: '$totalAmount' } } },
    ]),
  ]);
  const revenue = revenueAgg[0]?.revenue || 0;
  const byStatusAgg = await Order.aggregate([
    { $group: { _id: '$status', count: { $sum: 1 } } },
  ]);
  const byStatus = Object.fromEntries(byStatusAgg.map((x) => [x._id, x.count]));
  res.json({ users, products, orders, revenue, byStatus });
});

export default router;
