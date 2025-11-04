import 'package:store_app/services/api_service.dart';

/// Repository sản phẩm: gọi REST API để lấy danh sách sản phẩm
class ProductRepository {
  ProductRepository._();
  static final instance = ProductRepository._();

  /// Lấy danh sách sản phẩm, có thể lọc theo [category] và giới hạn [limit]
  Future<List<Map<String, dynamic>>> fetchProducts({String? category, int limit = 50}) async {
    // Gọi API lấy danh sách sản phẩm, có thể truyền category và limit.
    // Server hỗ trợ query ?category=Men&limit=50
    final items = await ApiService.instance.getJsonList('/api/products', query: {
      if (category != null && category.isNotEmpty) 'category': category,
      'limit': '$limit',
    });
    // Ép kiểu List<dynamic> -> List<Map<String,dynamic>> tiện cho UI
    return items.cast<Map<String, dynamic>>();
  }
}
