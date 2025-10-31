import mongoose from 'mongoose';

const ProductSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    category: { type: String, default: 'Shoes', index: true },
    price: { type: Number, required: true }, // VND
    imageUrl: { type: String, default: '' },
    description: { type: String, default: '' },
    stock: { type: Number, default: 0 },
  },
  { timestamps: true }
);

export default mongoose.model('Product', ProductSchema);
