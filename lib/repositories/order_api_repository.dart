import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:store_app/services/api_service.dart';

/// Repository đơn hàng: tạo đơn, lấy danh sách của tôi/tất cả, cập nhật trạng thái
class OrderApiRepository {
  OrderApiRepository._();
  static final instance = OrderApiRepository._();

  /// Tạo đơn hàng từ body (yêu cầu token)
  Future<Map<String, dynamic>> createOrder(String token, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiService.instance.baseUrl}/api/orders');
    final res = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Create order failed: ${res.statusCode} ${res.body}');
  }

  /// Lấy danh sách đơn hàng của chính người dùng (Bearer token)
  Future<List<dynamic>> myOrders(String token) async {
    final uri = Uri.parse('${ApiService.instance.baseUrl}/api/orders/my');
    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is List) return data;
    }
    throw Exception('Fetch my orders failed');
  }

  /// Lấy toàn bộ đơn hàng (admin)
  Future<List<dynamic>> allOrders(String token) async {
    final uri = Uri.parse('${ApiService.instance.baseUrl}/api/orders');
    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is List) return data;
    }
    throw Exception('Fetch orders failed');
  }

  /// Cập nhật trạng thái đơn hàng (admin) theo id
  Future<Map<String, dynamic>> updateStatus(String token, String id, String status) async {
    final uri = Uri.parse('${ApiService.instance.baseUrl}/api/orders/$id/status');
    final res = await http.patch(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Update status failed');
  }
}
