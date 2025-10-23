enum UserRole { user, admin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? photoUrl;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
  });

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

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role.name,
        if (photoUrl != null) 'photoUrl': photoUrl,
      };
}
