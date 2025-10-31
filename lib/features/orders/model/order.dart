enum OrderStatus{ active, completed, cancelled }

class Order {
  final String orderNumber;
  final int itemCount;
  final double totalAmount;
  final OrderStatus status;
  final String imageUrl;
  final DateTime orderDate;

  Order({
    required this.orderNumber,
    required this.itemCount,
    required this.totalAmount,
    required this.status,
    required this.imageUrl,
    required this.orderDate,
  });

  String get statusString => status.name;
  String get dateString => '${orderDate.year}-${orderDate.month.toString().padLeft(2,'0')}-${orderDate.day.toString().padLeft(2,'0')}';
}
