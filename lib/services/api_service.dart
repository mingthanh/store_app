import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// ApiService
/// - Đầu mối gọi HTTP tới server Node/Express (MongoDB)
/// - Tự động xác định baseUrl phù hợp từng nền tảng (Web/Desktop vs Android emulator)
/// - Có thể override bằng --dart-define API_BASE_URL
class ApiService {
  ApiService._();
  static final instance = ApiService._();

  String? _baseUrl;

  // Trả về baseUrl mặc định theo platform, cho phép override qua --dart-define.
  String get baseUrl => _baseUrl ??= _resolveBaseUrl();

  /// Xác định base URL
  /// - Nếu truyền --dart-define=API_BASE_URL=... thì dùng giá trị đó
  /// - Web/desktop/iOS simulator: localhost
  /// - Android emulator: 10.0.2.2 (loopback tới host)
  String _resolveBaseUrl() {
    // Lấy biến môi trường build-time nếu có (flutter run --dart-define=API_BASE_URL=...)
    const defined = String.fromEnvironment('API_BASE_URL');
    if (defined.isNotEmpty) return defined;
    if (kIsWeb) {
      // Web dùng localhost; có thể override bằng --dart-define nếu cần
      return 'http://localhost:3000';
    }
    if (Platform.isAndroid) {
      // Android emulator cần dùng IP loopback đặc biệt
      // 10.0.2.2 trỏ về máy host từ trong emulator
      return 'http://10.0.2.2:3000';
    }
    // Windows/macOS/Linux/iOS simulators
    return 'http://localhost:3000';
  }

  /// Gọi GET trả về List JSON
  /// [path]: đường dẫn API (vd: /api/products)
  /// [query]: query string (vd: {'limit':'20'})
  Future<List<dynamic>> getJsonList(String path, {Map<String, String>? query}) async {
    // Tạo URI từ baseUrl + path và append query nếu có
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    // Gọi GET nội dung JSON
    final res = await http.get(uri, headers: {'Content-Type': 'application/json'});
    if (res.statusCode >= 200 && res.statusCode < 300) {
      // Parse JSON string -> dynamic object
      final data = jsonDecode(res.body);
      if (data is List) return data;
      throw Exception('Expected list from $path');
    }
    throw Exception('GET $path failed: ${res.statusCode} ${res.body}');
  }

  /// Gọi GET trả về Map JSON (có thể kèm Bearer token)
  Future<Map<String, dynamic>> getJsonMap(String path, {Map<String, String>? query, String? token}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    // Nếu có token thì add header Authorization: Bearer <token>
    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
      throw Exception('Expected map from $path');
    }
    throw Exception('GET $path failed: ${res.statusCode} ${res.body}');
  }

  /// Gọi POST JSON
  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    // Encode body thành JSON string và gửi đi
    final res = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
  }

  /// Gọi PUT JSON
  Future<Map<String, dynamic>> putJson(String path, Map<String, dynamic> body, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.put(uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('PUT $path failed: ${res.statusCode} ${res.body}');
  }

  /// Gọi DELETE, trả về true nếu thành công
  Future<bool> delete(String path, {String? token}) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.delete(uri, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    // Các API REST thường trả 204 No Content hoặc 200 OK cho delete thành công
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return true;
    }
    throw Exception('DELETE $path failed: ${res.statusCode} ${res.body}');
  }
}
