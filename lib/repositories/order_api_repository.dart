import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:store_app/services/api_service.dart';

class OrderApiRepository {
  OrderApiRepository._();
  static final instance = OrderApiRepository._();

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
