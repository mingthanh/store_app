import mongoose from 'mongoose';

const UserSchema = new mongoose.Schema(
  {
    name: { type: String, default: '' },
    email: { type: String, required: true, unique: true, index: true },
    passwordHash: { type: String, default: '' }, // Not required for social users
    // 0 = admin, 1 = user
    role: { type: Number, default: 1 },
    // Optional profile fields
    phone: { type: String, default: '' },
    avatarUrl: { type: String, default: '' },
    // Firebase UID for social login users
    firebaseUid: { type: String, sparse: true, index: true },
  },
  { timestamps: true }
);

export default mongoose.model('User', UserSchema);
