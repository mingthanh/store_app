import 'package:store_app/services/api_service.dart';

/// Repository thao tác dành cho Admin (thống kê và CRUD sản phẩm)
class AdminRepository {
  AdminRepository._();
  static final instance = AdminRepository._();

  /// Lấy thống kê tổng quan cho dashboard admin
  Future<Map<String, dynamic>> getStats(String token) async {
    return ApiService.instance.getJsonMap('/api/admin/stats', token: token);
  }

  /// Tạo sản phẩm mới
  Future<Map<String, dynamic>> createProduct(String token, Map<String, dynamic> body) async {
    return ApiService.instance.postJson('/api/products', body, token: token);
  }

  /// Cập nhật sản phẩm theo id
  Future<Map<String, dynamic>> updateProduct(String token, String id, Map<String, dynamic> body) async {
    return ApiService.instance.putJson('/api/products/$id', body, token: token);
  }

  /// Xóa sản phẩm theo id
  Future<bool> deleteProduct(String token, String id) async {
    return ApiService.instance.delete('/api/products/$id', token: token);
  }
}
