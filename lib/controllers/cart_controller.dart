import 'package:get/get.dart';
import 'package:store_app/models/product.dart';
import 'package:store_app/services/firestore_service.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem(this.product, this.quantity);
}

class CartController extends GetxController {
  final items = <int, CartItem>{}.obs; // key: product.id

  int get totalItems => items.values.fold(0, (acc, e) => acc + e.quantity);
  double get totalPrice => items.values.fold(0.0, (acc, e) => acc + e.product.price * e.quantity);

  void add(Product p, {int qty = 1}) {
    final existing = items[p.id];
    if (existing != null) {
      existing.quantity += qty;
      items[p.id] = CartItem(existing.product, existing.quantity);
    } else {
      items[p.id] = CartItem(p, qty);
    }
    items.refresh();
  }

  void increment(Product p) => add(p, qty: 1);

  void decrement(Product p) {
    final existing = items[p.id];
    if (existing == null) return;
    existing.quantity -= 1;
    if (existing.quantity <= 0) {
      items.remove(p.id);
    } else {
      items[p.id] = CartItem(existing.product, existing.quantity);
    }
    items.refresh();
  }

  void remove(Product p) {
    items.remove(p.id);
    items.refresh();
  }

  Future<String?> checkout(String userId) async {
    if (items.isEmpty) return null;
    // Map items to a minimal payload
    final orderItems = items.values
        .map((e) => {
              'productId': e.product.id,
              'name': e.product.name,
              'price': (e.product.price * 100).round(), // cents
              'quantity': e.quantity,
            })
        .toList();
    final totalCents = (totalPrice * 100).round();
    final orderId = await FirestoreService.instance.createOrder(
      userId: userId,
      items: orderItems,
      totalAmount: totalCents,
      status: 'processing',
    );
    items.clear();
    items.refresh();
    return orderId;
  }
}
