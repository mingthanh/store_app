import 'package:flutter/material.dart';

class TrackingStatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const TrackingStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    
    if (compact) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: config.color,
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: config.color.withAlpha((0.3 * 255).round()),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status) {
      case 'pending':
        return _StatusConfig(
          color: Colors.orange,
          label: 'Chờ xử lý',
          icon: Icons.pending,
        );
      case 'processing':
        return _StatusConfig(
          color: Colors.blue,
          label: 'Đang xử lý',
          icon: Icons.autorenew,
        );
      case 'picked_up':
        return _StatusConfig(
          color: Colors.blue,
          label: 'Đã lấy hàng',
          icon: Icons.inventory_2,
        );
      case 'in_transit':
        return _StatusConfig(
          color: Colors.orange,
          label: 'Đang vận chuyển',
          icon: Icons.local_shipping,
        );
      case 'arrived_hub':
        return _StatusConfig(
          color: Colors.purple,
          label: 'Đã tới trung tâm',
          icon: Icons.warehouse,
        );
      case 'out_for_delivery':
        return _StatusConfig(
          color: Colors.indigo,
          label: 'Đang giao hàng',
          icon: Icons.delivery_dining,
        );
      case 'shipped':
        return _StatusConfig(
          color: Colors.purple,
          label: 'Đang giao',
          icon: Icons.local_shipping,
        );
      case 'delivered':
        return _StatusConfig(
          color: Colors.green,
          label: 'Đã giao',
          icon: Icons.check_circle,
        );
      case 'cancelled':
        return _StatusConfig(
          color: Colors.red,
          label: 'Đã hủy',
          icon: Icons.cancel,
        );
      default:
        return _StatusConfig(
          color: Colors.grey,
          label: status,
          icon: Icons.info,
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final String label;
  final IconData icon;

  _StatusConfig({
    required this.color,
    required this.label,
    required this.icon,
  });
}
