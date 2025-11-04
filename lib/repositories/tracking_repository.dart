import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:store_app/models/tracking_history_model.dart';
import 'package:store_app/services/api_service.dart';
import 'package:store_app/controllers/api_auth_controller.dart';
import 'package:get/get.dart';

class TrackingRepository {
  static final TrackingRepository instance = TrackingRepository._();
  TrackingRepository._();

  final _baseUrl = ApiService.instance.baseUrl;

  String? _getToken() {
    final authCtrl = Get.find<ApiAuthController>();
    return authCtrl.token.value;
  }

  /// Scan QR and update location
  Future<Map<String, dynamic>> scanQR({
    required String trackingId,
    required String locationName,
    required double latitude,
    required double longitude,
    required String status,
    String? notes,
  }) async {
    final token = _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$_baseUrl/api/tracking/scan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'trackingId': trackingId,
        'locationName': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'notes': notes,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Scan failed');
    }
  }

  /// Get tracking history by trackingId
  Future<Map<String, dynamic>> getTracking(String trackingId) async {
    final token = _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/tracking/$trackingId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'order': data['order'],
        'history': (data['history'] as List)
            .map((e) => TrackingHistoryModel.fromJson(e))
            .toList(),
        'customer': data['customer'],
      };
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get tracking');
    }
  }

  /// Get tracking by orderId
  Future<Map<String, dynamic>> getTrackingByOrderId(String orderId) async {
    final token = _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/tracking/order/$orderId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'trackingId': data['trackingId'],
        'history': (data['history'] as List)
            .map((e) => TrackingHistoryModel.fromJson(e))
            .toList(),
        'currentLocation': data['currentLocation'],
        'status': data['status'],
      };
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to get tracking');
    }
  }
}
