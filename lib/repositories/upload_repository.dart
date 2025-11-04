import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:store_app/services/api_service.dart';

/// Repository upload ảnh lên server (Multer), trả về URL ảnh tuyệt đối
class UploadRepository {
  UploadRepository._();
  static final instance = UploadRepository._();

  // Returns the absolute image URL to use in the app
  /// Upload ảnh từ bytes với tên file [filename]
  /// - Backend yêu cầu field 'image' (single upload)
  /// - Trả về URL đầy đủ để hiển thị trong app
  Future<String> uploadImageBytes(String token, Uint8List bytes, String filename) async {
    // Tạo MultipartRequest POST tới /api/uploads/images
    final uri = Uri.parse('${ApiService.instance.baseUrl}/api/uploads/images');
    final req = http.MultipartRequest('POST', uri);
    // Đính kèm Bearer token để server xác thực quyền admin
    req.headers['Authorization'] = 'Bearer $token';
    // Đặt field file là 'image' (khớp với backend Multer single('image'))
    req.files.add(http.MultipartFile.fromBytes('image', bytes, filename: filename));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final path = (data['url'] ?? data['path'] ?? '').toString();
      if (path.isEmpty) throw Exception('Invalid upload response');
      // If server returned a relative path, prefix with baseUrl
      if (path.startsWith('http://') || path.startsWith('https://')) return path;
      return '${ApiService.instance.baseUrl}$path';
    }
    throw Exception('Upload failed: ${res.statusCode} ${res.body}');
  }
}
