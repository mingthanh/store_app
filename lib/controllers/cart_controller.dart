import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_app/models/product.dart';
import 'package:store_app/services/firestore_service.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// Mô hình đại diện cho một sản phẩm trong giỏ hàng
/// Chứa thông tin sản phẩm và số lượng
class CartItem {
  final Product product; // Thông tin sản phẩm
  int quantity; // Số lượng sản phẩm trong giỏ hàng
  CartItem(this.product, this.quantity);

  // Chuyển đổi sang JSON để lưu trữ trong bộ nhớ cục bộ
  Map<String, dynamic> toJson() => {
    'product': {
      'id': product.id,
      'name': product.name,
      'category': product.category,
      'price': product.price,
      'oldPrice': product.oldPrice,
      'imageUrl': product.imageUrl,
      'description': product.description,
    },
    'quantity': quantity,
  };

  /// Tạo CartItem từ dữ liệu JSON được lưu trữ
  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productData = json['product'] as Map<String, dynamic>;
    return CartItem(
      Product(
        id: productData['id'] ?? 0,
        name: productData['name'] ?? '',
        category: productData['category'] ?? '',
        price: (productData['price'] ?? 0.0).toDouble(),
        oldPrice: productData['oldPrice']?.toDouble(),
        imageUrl: productData['imageUrl'] ?? '',
        description: productData['description'] ?? '',
      ),
      json['quantity'] ?? 1,
    );
  }
}

/// Controller quản lý giỏ hàng của người dùng
/// Xử lý thêm, xóa, cập nhật sản phẩm và lưu trữ dữ liệu
class CartController extends GetxController {
  final _storage = GetStorage(); // Bộ nhớ cục bộ để lưu giỏ hàng
  final items = <int, CartItem>{}.obs; // Danh sách sản phẩm trong giỏ: key = product.id
  String? _currentUserId; // ID người dùng hiện tại

  /// Tổng số lượng sản phẩm trong giỏ hàng
  int get totalItems => items.values.fold(0, (acc, e) => acc + e.quantity);
  
  /// Tổng giá trị đơn hàng
  double get totalPrice => items.values.fold(0.0, (acc, e) => acc + e.product.price * e.quantity);

  /// Tải giỏ hàng cho người dùng cụ thể từ bộ nhớ cục bộ
  void loadUserCart(String? userId) {
    if (_currentUserId == userId) return; // Đã tải cho người dùng này rồi
    
    _currentUserId = userId;
    items.clear();
    
    if (userId == null || userId.isEmpty) {
      debugPrint('[Cart] Không có user ID, giữ giỏ hàng trống');
      return;
    }
    
    try {
      final stored = _storage.read('cart_$userId') as Map<String, dynamic>?;
      if (stored != null) {
        stored.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            final cartItem = CartItem.fromJson(value);
            items[int.parse(key)] = cartItem;
          }
        });
      }
      debugPrint('[Cart] Đã tải ${items.length} sản phẩm cho user $userId');
    } catch (e) {
      debugPrint('[Cart] Lỗi khi tải giỏ hàng cho user $userId: $e');
    }
    items.refresh();
  }

  /// Lưu giỏ hàng hiện tại vào bộ nhớ cục bộ
  void _saveCart() {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;
    
    try {
      final data = <String, dynamic>{};
      items.forEach((key, item) {
        data[key.toString()] = item.toJson();
      });
      
      _storage.write('cart_${_currentUserId!}', data);
      debugPrint('[Cart] Đã lưu ${items.length} sản phẩm cho user $_currentUserId');
    } catch (e) {
      debugPrint('[Cart] Lỗi khi lưu giỏ hàng cho user $_currentUserId: $e');
    }
  }

  /// Thêm sản phẩm vào giỏ hàng hoặc tăng số lượng nếu đã có
  void add(Product p, {int qty = 1}) {
    final existing = items[p.id];
    if (existing != null) {
      existing.quantity += qty;
      items[p.id] = CartItem(existing.product, existing.quantity);
    } else {
      items[p.id] = CartItem(p, qty);
    }
    _saveCart();
    items.refresh();
  }

  /// Tăng số lượng sản phẩm lên 1
  void increment(Product p) => add(p, qty: 1);

  /// Giảm số lượng sản phẩm xuống 1, xóa khỏi giỏ nếu số lượng = 0
  void decrement(Product p) {
    final existing = items[p.id];
    if (existing == null) return;
    existing.quantity -= 1;
    if (existing.quantity <= 0) {
      items.remove(p.id);
    } else {
      items[p.id] = CartItem(existing.product, existing.quantity);
    }
    _saveCart();
    items.refresh();
  }

  /// Xóa hoàn toàn sản phẩm khỏi giỏ hàng
  void remove(Product p) {
    items.remove(p.id);
    _saveCart();
    items.refresh();
  }

  /// Xóa tất cả dữ liệu người dùng khi đăng xuất
  void clearUserData() {
    _currentUserId = null;
    items.clear();
    items.refresh();
  }

  /// Xóa giỏ hàng hiện tại và cập nhật lưu trữ cục bộ (dùng sau khi checkout thành công)
  void clearAndPersist() {
    /// Xóa toàn bộ giỏ hàng hiện tại và lưu trạng thái rỗng xuống bộ nhớ cục bộ
    /// Dùng sau khi checkout thành công để đảm bảo giỏ hàng trống
    items.clear();
    _saveCart();
    items.refresh();
  }

  /// Thực hiện thanh toán đơn hàng và tạo order trong Firestore
  /// Trả về orderId nếu thành công, null nếu giỏ hàng trống
  Future<String?> checkout(String userId) async {
    if (items.isEmpty) return null;
    
    // Chuyển đổi items thành format tối giản cho API
    final orderItems = items.values
        .map((e) => {
              'productId': e.product.id,
              'name': e.product.name,
              'price': (e.product.price * 100).round(), // Chuyển sang cent
              'quantity': e.quantity,
            })
        .toList();
    final totalCents = (totalPrice * 100).round();
    
    // Tạo order trong Firestore
    final orderId = await FirestoreService.instance.createOrder(
      userId: userId,
      items: orderItems,
      totalAmount: totalCents,
      status: 'processing',
    );
    
    // Xóa giỏ hàng sau khi thanh toán thành công
    clearAndPersist();
    return orderId;
  }
}
