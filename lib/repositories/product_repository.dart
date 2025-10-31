import 'package:store_app/services/api_service.dart';

class ProductRepository {
  ProductRepository._();
  static final instance = ProductRepository._();

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
