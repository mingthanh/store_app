import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:store_app/services/api_service.dart';

class UserRepository {
  UserRepository._();
  static final instance = UserRepository._();

  Future<List<dynamic>> fetchUsers(String token) async {
    final uri = Uri.parse('${ApiService.instance.baseUrl}/api/users');
    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is List) return data;
    }
    throw Exception('Fetch users failed');
  }

  Future<Map<String, dynamic>> updateUser(String token, String id, {String? name, int? role}) async {
    final uri = Uri.parse('${ApiService.instance.baseUrl}/api/users/$id');
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (role != null) body['role'] = role;
    final res = await http.put(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Update user failed');
  }

  Future<Map<String, dynamic>> getMe(String token) async {
    final uri = Uri.parse('${ApiService.instance.baseUrl}/api/users/me');
    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Get profile failed');
  }

  /// Generate API token for social login users
  Future<Map<String, dynamic>> createSocialToken({
    required String firebaseUid,
    required String email,
    String? name,
  }) async {
    final uri = Uri.parse('${ApiService.instance.baseUrl}/api/auth/social-token');
    final res = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firebaseUid': firebaseUid,
          'email': email,
          'name': name,
        }));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Social token creation failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> updateMe(String token, {String? name, String? phone, String? avatarUrl}) async {
    final uri = Uri.parse('${ApiService.instance.baseUrl}/api/users/me');
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
    final res = await http.put(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Update profile failed');
  }
}
