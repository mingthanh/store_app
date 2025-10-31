import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ApiAuthService {
  ApiAuthService._();
  static final instance = ApiAuthService._();

  Future<Map<String, dynamic>> register({required String name, required String email, required String password, int role = 1}) async {
    final uri = Uri.parse('${ApiService.instance.baseUrl}/api/auth/register');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    // try parse server error message
    try {
      final m = jsonDecode(res.body) as Map<String, dynamic>;
      final msg = (m['error'] ?? m['message'] ?? '').toString();
      if (msg.isNotEmpty) throw Exception(msg);
    } catch (_) {}
    if (res.statusCode == 409) {
      throw Exception('email already exists');
    }
    throw Exception('Register failed: HTTP ${res.statusCode}');
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final uri = Uri.parse('${ApiService.instance.baseUrl}/api/auth/login');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    try {
      final m = jsonDecode(res.body) as Map<String, dynamic>;
      final msg = (m['error'] ?? m['message'] ?? '').toString();
      if (msg.isNotEmpty) throw Exception(msg);
    } catch (_) {}
    if (res.statusCode == 401) {
      throw Exception('invalid credentials');
    }
    throw Exception('Login failed: HTTP ${res.statusCode}');
  }
}
