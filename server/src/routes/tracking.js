import { Router } from 'express';
import jwt from 'jsonwebtoken';
import TrackingHistory from '../models/TrackingHistory.js';
import Order from '../models/Order.js';
import User from '../models/User.js';

const router = Router();

// Middleware: Verify JWT token
function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key-here');
    req.userId = decoded.id;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}

// POST /api/tracking/scan - Staff scan QR and update location
router.post('/scan', authMiddleware, async (req, res) => {
  try {
    const { trackingId, locationName, latitude, longitude, status, notes } = req.body;
    
    // Validation
    if (!trackingId || !locationName || !latitude || !longitude || !status) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Verify user is staff (role !== 1)
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    if (user.role === 1) {
      return res.status(403).json({ error: 'Only staff can scan orders' });
    }

    // Find order by trackingId
    const order = await Order.findOne({ trackingId });
    if (!order) {
      return res.status(404).json({ error: 'Order not found with this tracking ID' });
    }

    // Create tracking history entry
    const trackingEntry = await TrackingHistory.create({
      orderId: order._id,
      locationName,
      latitude,
      longitude,
      scannedBy: req.userId,
      status,
      notes: notes || undefined,
      timestamp: new Date()
    });

    // Update order
    order.trackingHistory.push(trackingEntry._id);
    order.currentLocation = {
      name: locationName,
      latitude,
      longitude,
      updatedAt: new Date()
    };

    // Update order status if delivered
    if (status === 'delivered') {
      order.status = 'delivered';
    } else if (status === 'out_for_delivery') {
      order.status = 'shipped';
    } else if (status === 'picked_up' && order.status === 'pending') {
      order.status = 'processing';
    }

    await order.save();

    console.log(`[Tracking] Order ${trackingId} updated at ${locationName}`);

    res.json({
      success: true,
      message: 'Location updated successfully',
      trackingEntry: {
        id: trackingEntry._id,
        locationName: trackingEntry.locationName,
        status: trackingEntry.status,
        timestamp: trackingEntry.timestamp
      },
      order: {
        id: order._id,
        trackingId: order.trackingId,
        status: order.status,
        currentLocation: order.currentLocation
      }
    });

  } catch (error) {
    console.error('[Tracking Scan Error]', error);
    res.status(500).json({ error: error.message });
  }
});

// GET /api/tracking/:trackingId - Get tracking history
router.get('/:trackingId', authMiddleware, async (req, res) => {
  try {
    const { trackingId } = req.params;

    const order = await Order.findOne({ trackingId })
      .populate('userId', 'name email')
      .populate({
        path: 'trackingHistory',
        populate: { path: 'scannedBy', select: 'name email' },
        options: { sort: { timestamp: 1 } }
      });

    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    // Check permission: customer can only see own orders
    const user = await User.findById(req.userId);
    if (user.role === 1 && order.userId._id.toString() !== req.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json({
      order: {
        id: order._id,
        trackingId: order.trackingId,
        status: order.status,
        currentLocation: order.currentLocation,
        totalAmount: order.totalAmount,
        createdAt: order.createdAt
      },
      history: order.trackingHistory,
      customer: {
        name: order.userId.name,
        email: order.userId.email
      }
    });

  } catch (error) {
    console.error('[Tracking Get Error]', error);
    res.status(500).json({ error: error.message });
  }
});

// GET /api/tracking/order/:orderId - Get by orderId (for internal use)
router.get('/order/:orderId', authMiddleware, async (req, res) => {
  try {
    const order = await Order.findById(req.params.orderId)
      .populate({
        path: 'trackingHistory',
        populate: { path: 'scannedBy', select: 'name' },
        options: { sort: { timestamp: 1 } }
      });

    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    // Check permission
    const user = await User.findById(req.userId);
    if (user.role === 1 && order.userId.toString() !== req.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json({
      trackingId: order.trackingId,
      history: order.trackingHistory,
      currentLocation: order.currentLocation,
      status: order.status
    });

  } catch (error) {
    console.error('[Tracking by OrderId Error]', error);
    res.status(500).json({ error: error.message });
  }
});

export default router;
