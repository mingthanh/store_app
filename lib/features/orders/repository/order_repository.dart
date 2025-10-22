import 'package:store_app/features/orders/model/order.dart';

class OrderRepository {
  List<Order> getOrders (){
    return[
      Order(
        orderNumber: '2612',
        itemCount: 2,
        totalAmount: 999.99,
        status: OrderStatus.active,
        imageUrl: 'assets/images/shoe.jpg',
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
      Order(
        orderNumber: '5511',
        itemCount: 5,
        totalAmount: 1999.99,
        status: OrderStatus.completed,
        imageUrl: 'assets/images/shoes2.jpg',
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
      Order(
        orderNumber: '2487',
        itemCount: 2,
        totalAmount: 2999.99,
        status: OrderStatus.cancelled,
        imageUrl: 'assets/images/shoes3.jpg',
        orderDate: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        Order(
          orderNumber: '2615',
        itemCount: 3,
        totalAmount: 499.99,
        status: OrderStatus.active,
        imageUrl: 'assets/images/shoes2.jpg',
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
    ];
  }
  List<Order> getActiveOrders(OrderStatus status){
    return getOrders().where((order) => order.status == status).toList();
  }
}
