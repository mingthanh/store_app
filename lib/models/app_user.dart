/// Enum định nghĩa các vai trò người dùng trong hệ thống
enum UserRole { user, admin }

/// Mô hình dữ liệu đại diện cho người dùng ứng dụng
/// Chứa thông tin cơ bản và vai trò của người dùng
class AppUser {
  final String id; // ID duy nhất của người dùng
  final String name; // Tên hiển thị
  final String email; // Địa chỉ email
  final UserRole role; // Vai trò: user hoặc admin
  final String? photoUrl; // URL ảnh đại diện (tùy chọn)

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
  });

  /// Tạo AppUser từ dữ liệu Firestore
  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    final roleStr = (data['role'] as String?)?.toLowerCase() ?? 'user';
    final role = roleStr == 'admin' ? UserRole.admin : UserRole.user;
    return AppUser(
      id: id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: role,
      photoUrl: data['photoUrl'] as String?,
    );
  }

  /// Chuyển đổi AppUser thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role.name,
        if (photoUrl != null) 'photoUrl': photoUrl,
      };
}
