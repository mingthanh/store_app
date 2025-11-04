import mongoose from 'mongoose';

const trackingHistorySchema = new mongoose.Schema({
  orderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order',
    required: true,
    index: true
  },
  locationName: {
    type: String,
    required: true
  },
  latitude: {
    type: Number,
    required: true
  },
  longitude: {
    type: Number,
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now,
    index: true
  },
  scannedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  status: {
    type: String,
    enum: ['picked_up', 'in_transit', 'arrived_hub', 'out_for_delivery', 'delivered'],
    required: true
  },
  notes: String
}, { timestamps: true });

// Index for faster queries
trackingHistorySchema.index({ orderId: 1, timestamp: 1 });

export default mongoose.model('TrackingHistory', trackingHistorySchema);
