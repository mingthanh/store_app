import dotenv from 'dotenv';
import mongoose from 'mongoose';
import Product from './models/Product.js';
import User from './models/User.js';
import Order from './models/Order.js';

dotenv.config();

const MONGO_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/store_app';

async function run() {
  try {
    await mongoose.connect(MONGO_URI, { dbName: process.env.MONGO_DB || 'store_app' });
    console.log('[MongoDB] connected');

    const exists = await Product.countDocuments();
    if (exists > 0) {
      console.log('Products exist, skip seeding');
    } else {
      await Product.insertMany([
        { name: 'Air Max White', price: 1990000, category: 'Shoes', imageUrl: 'https://picsum.photos/seed/airmax_white/600/600', description: 'Air Max trắng êm ái.', stock: 50 },
        { name: 'Air Max Black', price: 2050000, category: 'Shoes', imageUrl: 'https://picsum.photos/seed/airmax_black/600/600', description: 'Air Max đen dễ phối.', stock: 40 },
        { name: 'Jordan 1 Mid', price: 3290000, category: 'Shoes', imageUrl: 'https://picsum.photos/seed/jordan_mid/600/600', description: 'Jordan 1 Mid nổi bật.', stock: 25 },
      ]);
      console.log('Seeded products');
    }

    const usersExist = await User.countDocuments();
    if (usersExist === 0) {
      const bcrypt = await import('bcryptjs');
      const adminPass = await bcrypt.default.hash('admin123', 10);
      const userPass = await bcrypt.default.hash('user123', 10);
      const [admin, user] = await User.insertMany([
        { name: 'Admin', email: 'admin@example.com', passwordHash: adminPass, role: 0 },
        { name: 'User', email: 'user@example.com', passwordHash: userPass, role: 1 },
      ]);
      console.log('Seeded users:', admin.email, user.email);

      const someProducts = await Product.find().limit(2);
      if (someProducts.length > 0) {
        const total = someProducts.reduce((s, p) => s + p.price, 0);
        await Order.create({
          userId: user._id,
          items: someProducts.map((p) => ({ productId: p._id, name: p.name, price: p.price, quantity: 1 })),
          totalAmount: total,
          status: 'processing',
        });
        console.log('Seeded one demo order for stats');
      }
    }
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}

run();
