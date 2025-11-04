import mongoose from 'mongoose';

const OrderItemSchema = new mongoose.Schema(
  {
    // productId is optional for now to allow local demo products without IDs
    productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
    name: { type: String, required: true },
    price: { type: Number, required: true },
    quantity: { type: Number, required: true },
  },
  { _id: false }
);

const OrderSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    items: { type: [OrderItemSchema], default: [] },
    totalAmount: { type: Number, required: true },
    status: {
      type: String,
      default: 'pending',
      enum: ['pending', 'processing', 'shipped', 'delivered', 'cancelled'],
    },
    // Tracking fields
    trackingId: {
      type: String,
      unique: true,
      sparse: true, // Allow null for old orders
      index: true
    },
    currentLocation: {
      name: String,
      latitude: Number,
      longitude: Number,
      updatedAt: Date
    },
    trackingHistory: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'TrackingHistory'
    }]
  },
  { timestamps: true }
);

// Auto-generate trackingId on create
OrderSchema.pre('save', function(next) {
  if (this.isNew && !this.trackingId) {
    this.trackingId = `TRK${Date.now()}${Math.random().toString(36).substr(2, 6).toUpperCase()}`;
  }
  next();
});

export default mongoose.model('Order', OrderSchema);
