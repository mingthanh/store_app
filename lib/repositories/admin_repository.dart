import 'package:store_app/services/api_service.dart';

class AdminRepository {
  AdminRepository._();
  static final instance = AdminRepository._();

  Future<Map<String, dynamic>> getStats(String token) async {
    return ApiService.instance.getJsonMap('/api/admin/stats', token: token);
  }

  Future<Map<String, dynamic>> createProduct(String token, Map<String, dynamic> body) async {
    return ApiService.instance.postJson('/api/products', body, token: token);
  }

  Future<Map<String, dynamic>> updateProduct(String token, String id, Map<String, dynamic> body) async {
    return ApiService.instance.putJson('/api/products/$id', body, token: token);
  }

  Future<bool> deleteProduct(String token, String id) async {
    return ApiService.instance.delete('/api/products/$id', token: token);
  }
}
