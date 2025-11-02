import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_app/models/product.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// Controller quản lý danh sách yêu thích của người dùng
/// Xử lý thêm/xóa sản phẩm khỏi wishlist và lưu trữ dữ liệu
class WishlistController extends GetxController {
  final _storage = GetStorage(); // Bộ nhớ cục bộ để lưu wishlist
  final RxList<Product> _wishlist = <Product>[].obs; // Danh sách sản phẩm yêu thích
  String? _currentUserId; // ID người dùng hiện tại

  /// Getter để truy cập danh sách wishlist
  List<Product> get wishlist => _wishlist;

  /// Tải danh sách yêu thích cho người dùng cụ thể từ bộ nhớ cục bộ
  void loadUserWishlist(String? userId) {
    if (_currentUserId == userId) return; // Đã tải cho người dùng này rồi
    
    _currentUserId = userId;
    _wishlist.clear();
    
    if (userId == null || userId.isEmpty) {
      debugPrint('[Wishlist] Không có user ID, giữ wishlist trống');
      return;
    }
    
    try {
      final stored = _storage.read('wishlist_$userId') as List?;
      if (stored != null) {
        // Chuyển đổi dữ liệu đã lưu trở lại thành đối tượng Product
        for (final item in stored) {
          if (item is Map<String, dynamic>) {
            final product = Product(
              id: item['id'] ?? 0,
              name: item['name'] ?? '',
              category: item['category'] ?? '',
              price: (item['price'] ?? 0.0).toDouble(),
              oldPrice: item['oldPrice']?.toDouble(),
              imageUrl: item['imageUrl'] ?? '',
              description: item['description'] ?? '',
            );
            _wishlist.add(product);
          }
        }
      }
      debugPrint('[Wishlist] Đã tải ${_wishlist.length} sản phẩm cho user $userId');
    } catch (e) {
      debugPrint('[Wishlist] Lỗi khi tải wishlist cho user $userId: $e');
    }
    update();
  }

  /// Lưu danh sách yêu thích hiện tại vào bộ nhớ cục bộ
  void _saveWishlist() {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;
    
    try {
      final data = _wishlist.map((p) => {
        'id': p.id,
        'name': p.name,
        'category': p.category,
        'price': p.price,
        'oldPrice': p.oldPrice,
        'imageUrl': p.imageUrl,
        'description': p.description,
      }).toList();
      
      _storage.write('wishlist_${_currentUserId!}', data);
      debugPrint('[Wishlist] Đã lưu ${_wishlist.length} sản phẩm cho user $_currentUserId');
    } catch (e) {
      debugPrint('[Wishlist] Lỗi khi lưu wishlist cho user $_currentUserId: $e');
    }
  }

  /// Thêm hoặc xóa sản phẩm khỏi danh sách yêu thích
  void toggleFavorite(Product product) {
    if (_wishlist.contains(product)) {
      _wishlist.remove(product);
    } else {
      _wishlist.add(product);
    }
    _saveWishlist();
    update(); // Rebuild các widget GetBuilder
  }

  /// Kiểm tra xem sản phẩm có trong danh sách yêu thích không
  bool isFavorite(Product product) {
    return _wishlist.contains(product);
  }

  /// Xóa tất cả sản phẩm khỏi wishlist
  void clearWishlist() {
    _wishlist.clear();
    _saveWishlist();
    update();
  }

  /// Xóa tất cả dữ liệu người dùng khi đăng xuất
  void clearUserData() {
    _currentUserId = null;
    _wishlist.clear();
    update();
  }
}