import mongoose from 'mongoose';

const UserSchema = new mongoose.Schema(
  {
    name: { type: String, default: '' },
    email: { type: String, required: true, unique: true, index: true },
    passwordHash: { type: String, required: true },
    // 0 = admin, 1 = user
    role: { type: Number, default: 1 },
    // Optional profile fields
    phone: { type: String, default: '' },
    avatarUrl: { type: String, default: '' },
  },
  { timestamps: true }
);

export default mongoose.model('User', UserSchema);
