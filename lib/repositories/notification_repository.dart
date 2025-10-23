import 'package:store_app/widgets/notification_type.dart';

class NotificationRepository {
  List<NotificationItem> getNotifications() {
    return [
      NotificationItem(
        title: 'Order Placed',
        message: 'Your order #1234 has been placed successfully.',
        time: '2 hours ago',
        type: NotificationType.order,
        isRead: true,
      ),
      NotificationItem(
        title: 'Delivery Update',
        message: 'Your order #1234 is out for delivery.',
        time: '1 hour ago',
        type: NotificationType.deliver,
        isRead: false,
      ),
      NotificationItem(
        title: 'Special Promotion',
        message: 'Get 20% off on your next purchase!',
        time: '3 hours ago',
        type: NotificationType.promo,
        isRead: false,
      ),
      NotificationItem(
        title: 'Payment Received',
        message: 'Your payment for order #1234 has been received.',
        time: '4 hours ago',
        type: NotificationType.payment,
        isRead: true,
      ),
    ];
  }
}