import 'package:flutter/material.dart';
import 'package:store_app/widgets/notification_type.dart';

class NotificationUtil {
  static IconData getNotificationsIcon(NotificationType type) {
    switch (type){
      case NotificationType.order:
        return Icons.shopping_bag_outlined;
      case  NotificationType.deliver:
        return Icons.local_shipping_outlined;
      case  NotificationType.promo:
        return Icons.local_offer_outlined;
      case  NotificationType.payment:
        return Icons.payment_outlined;
    }
  }

  static Color getIconBackgroundColor(BuildContext context, NotificationType type) {
    switch (type){
      case NotificationType.order:
        return Theme.of(context)
            .primaryColor
            .withAlpha((0.1 * 255).round());
      case  NotificationType.deliver:
        return Colors.green[300]!;
      case  NotificationType.promo:
        return Colors.orange[300]!;
      case  NotificationType.payment:
        return Colors.pink[300]!;
    }
  }

  static Color getIconColor(BuildContext context, NotificationType type) {
    switch (type){
      case NotificationType.order:
        return Theme.of(context).primaryColor;
      case  NotificationType.deliver:
        return Colors.green[800]!;
      case  NotificationType.promo:
        return Colors.orange[800]!;
      case  NotificationType.payment:
        return Colors.pink[800]!;
    }
  }
}