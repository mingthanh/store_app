import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:store_app/services/api_auth_service.dart';
import 'package:store_app/controllers/auth_controller.dart';
import 'package:store_app/repositories/user_repository.dart';

/// Controller quản lý xác thực API cho hệ thống backend
/// Xử lý đăng nhập/đăng ký với email/password và quản lý token API
class ApiAuthController extends GetxController {
  final _storage = GetStorage(); // Bộ nhớ cục bộ để lưu thông tin đăng nhập

  // Trạng thái đăng nhập và thông tin người dùng
  final RxBool isLoggedIn = false.obs; // Trạng thái đã đăng nhập
  final RxInt roleNum = 1.obs; // Vai trò: 0=admin, 1=user
  final RxnString token = RxnString(); // Token xác thực API
  final RxnString userId = RxnString(); // ID người dùng
  final RxString name = ''.obs; // Tên người dùng
  final RxString email = ''.obs; // Email người dùng
  final RxString phone = ''.obs; // Số điện thoại
  final RxString avatarUrl = ''.obs; // URL ảnh đại diện
  final RxString lastError = ''.obs; // Lỗi cuối cùng
  final RxBool isSocialLogin = false.obs; // true khi đăng nhập qua Firebase social auth

  /// Getter để lấy tên vai trò dưới dạng string
  String get role => roleNum.value == 0 ? 'admin' : 'user';
  
  /// Kiểm tra xem người dùng có phải admin không
  bool get isAdmin => roleNum.value == 0;

  @override
  void onInit() {
    super.onInit();
    _restore(); // Khôi phục thông tin đăng nhập đã lưu
  }

  /// Khôi phục thông tin đăng nhập từ bộ nhớ cục bộ
  void _restore() {
    token.value = _storage.read('api_token');
    roleNum.value = _storage.read('api_role') ?? 1;
    userId.value = _storage.read('api_userId');
    name.value = _storage.read('api_name') ?? '';
    email.value = _storage.read('api_email') ?? '';
    phone.value = _storage.read('api_phone') ?? '';
    avatarUrl.value = _storage.read('api_avatarUrl') ?? '';
    isSocialLogin.value = _storage.read('api_social') ?? false;
    isLoggedIn.value = (token.value != null && token.value!.isNotEmpty) || isSocialLogin.value;
  }

  /// Đăng nhập bằng email và mật khẩu
  Future<bool> signInWithEmail(String emailInput, String password) async {
    try {
      lastError.value = '';
      final res = await ApiAuthService.instance.login(email: emailInput, password: password);
      final t = (res['token'] as String?);
      final u = res['user'] as Map<String, dynamic>;
      if (t == null) return false;
      token.value = t;
      userId.value = u['id']?.toString();
      name.value = (u['name'] ?? '').toString();
      email.value = (u['email'] ?? '').toString();
      roleNum.value = (u['role'] as num?)?.toInt() ?? 1;
      isLoggedIn.value = true;

      // Lưu thông tin đăng nhập vào bộ nhớ cục bộ
      _storage.write('api_token', token.value);
      _storage.write('api_userId', userId.value);
      _storage.write('api_name', name.value);
      _storage.write('api_email', email.value);
      _storage.write('api_role', roleNum.value);
      _storage.write('api_phone', phone.value);
      _storage.write('api_avatarUrl', avatarUrl.value);
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      lastError.value = msg;
      debugPrint('[ApiAuth] Lỗi đăng nhập: $msg');
      return false;
    }
  }

  /// Đăng ký tài khoản mới bằng email
  Future<bool> signUpWithEmail(String nameInput, String emailInput, String password) async {
    try {
      lastError.value = '';
      final res = await ApiAuthService.instance.register(name: nameInput, email: emailInput, password: password, role: 1);
      final t = (res['token'] as String?);
      final u = res['user'] as Map<String, dynamic>;
      if (t == null) return false;
      token.value = t;
      userId.value = u['id']?.toString();
      name.value = (u['name'] ?? '').toString();
      email.value = (u['email'] ?? '').toString();
      roleNum.value = (u['role'] as num?)?.toInt() ?? 1;
      isLoggedIn.value = true;

      // Lưu thông tin đăng ký vào bộ nhớ cục bộ
      _storage.write('api_token', token.value);
      _storage.write('api_userId', userId.value);
      _storage.write('api_name', name.value);
      _storage.write('api_email', email.value);
      _storage.write('api_role', roleNum.value);
      _storage.write('api_phone', phone.value);
      _storage.write('api_avatarUrl', avatarUrl.value);
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      lastError.value = msg;
      debugPrint('[ApiAuth] Lỗi đăng ký: $msg');
      return false;
    }
  }

  /// Đăng xuất khỏi hệ thống và xóa tất cả dữ liệu đăng nhập
  Future<void> signOut() async {
    token.value = null;
    isLoggedIn.value = false;
    lastError.value = '';
    isSocialLogin.value = false;
    
    // Xóa tất cả dữ liệu khỏi bộ nhớ cục bộ
    _storage.remove('api_token');
    _storage.remove('api_userId');
    _storage.remove('api_name');
    _storage.remove('api_email');
    _storage.remove('api_role');
    _storage.remove('api_phone');
    _storage.remove('api_avatarUrl');
    _storage.remove('api_social');

    // Đăng xuất Firebase/social auth nếu AuthController tồn tại
    if (Get.isRegistered<AuthController>()) {
      try {
        Get.find<AuthController>().signOut();
      } catch (e) {
        debugPrint('[ApiAuth] Lỗi đăng xuất AuthController: $e');
      }
    }
  }

  /// Làm mới thông tin hồ sơ người dùng từ server
  Future<bool> refreshProfile() async {
    final t = token.value;
    if (t == null) return false;
    try {
      final me = await UserRepository.instance.getMe(t);
      name.value = (me['name'] ?? '').toString();
      email.value = (me['email'] ?? '').toString();
      phone.value = (me['phone'] ?? '').toString();
      avatarUrl.value = (me['avatarUrl'] ?? '').toString();
      
      // Lưu thông tin đã cập nhật
      _storage.write('api_name', name.value);
      _storage.write('api_email', email.value);
      _storage.write('api_phone', phone.value);
      _storage.write('api_avatarUrl', avatarUrl.value);
      return true;
    } catch (e) {
      debugPrint('[ApiAuth] Lỗi làm mới hồ sơ: $e');
      return false;
    }
  }

  /// Cập nhật thông tin hồ sơ người dùng lên server
  Future<bool> updateProfile({String? newName, String? newPhone, String? newAvatarUrl}) async {
    final t = token.value;
    if (t == null) return false;
    try {
      final res = await UserRepository.instance.updateMe(t, name: newName, phone: newPhone, avatarUrl: newAvatarUrl);
      name.value = (res['name'] ?? name.value).toString();
      phone.value = (res['phone'] ?? phone.value).toString();
      avatarUrl.value = (res['avatarUrl'] ?? avatarUrl.value).toString();
      
      // Lưu thông tin đã cập nhật
      _storage.write('api_name', name.value);
      _storage.write('api_phone', phone.value);
      _storage.write('api_avatarUrl', avatarUrl.value);
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      lastError.value = msg;
      debugPrint('[ApiAuth] Lỗi cập nhật hồ sơ: $msg');
      return false;
    }
  }

  /// Đồng bộ dữ liệu từ Firebase social login để AccountScreen có thể hiển thị thông tin
  void setSocialProfile({
    String? firebaseUserId,
    String? displayName,
    String? emailAddress,
    String? avatar,
    String roleString = 'user',
  }) async {
    userId.value = firebaseUserId;
    name.value = (displayName ?? '').trim();
    email.value = (emailAddress ?? '').trim();
    avatarUrl.value = (avatar ?? '').trim();
    roleNum.value = roleString.toLowerCase() == 'admin' ? 0 : 1;
    isSocialLogin.value = true;
    isLoggedIn.value = true;

    // Lưu thông tin social login
    _storage.write('api_userId', userId.value);
    _storage.write('api_name', name.value);
    _storage.write('api_email', email.value);
    _storage.write('api_avatarUrl', avatarUrl.value);
    _storage.write('api_role', roleNum.value);
    _storage.write('api_social', true);

    // Thử tạo API token cho người dùng social login
    _createSocialToken(firebaseUserId, emailAddress, displayName);
  }

  /// Tạo API token cho người dùng social login (hoạt động nền)
  void _createSocialToken(String? firebaseUid, String? email, String? name) async {
    if (firebaseUid == null || email == null || email.isEmpty) return;
    
    try {
      debugPrint('[ApiAuth] Đang tạo social token cho Firebase UID: $firebaseUid');
      final response = await UserRepository.instance.createSocialToken(
        firebaseUid: firebaseUid,
        email: email,
        name: name,
      );
      
      final apiToken = response['token'] as String?;
      if (apiToken != null && apiToken.isNotEmpty) {
        token.value = apiToken;
        _storage.write('api_token', apiToken);
        debugPrint('[ApiAuth] Tạo social token thành công');
      }
    } catch (e) {
      debugPrint('[ApiAuth] Lỗi tạo social token: $e');
      // Không throw error - đây là hoạt động nền
      // Người dùng social vẫn có thể sử dụng app mà không có tính năng Orders
    }
  }
}
