import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:store_app/services/api_auth_service.dart';
import 'package:store_app/repositories/user_repository.dart';

class ApiAuthController extends GetxController {
  final _storage = GetStorage();

  final RxBool isLoggedIn = false.obs;
  final RxInt roleNum = 1.obs; // 0=admin,1=user
  final RxnString token = RxnString();
  final RxnString userId = RxnString();
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final RxString avatarUrl = ''.obs;
  final RxString lastError = ''.obs;

  String get role => roleNum.value == 0 ? 'admin' : 'user';
  bool get isAdmin => roleNum.value == 0;

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  void _restore() {
    token.value = _storage.read('api_token');
    roleNum.value = _storage.read('api_role') ?? 1;
    userId.value = _storage.read('api_userId');
    name.value = _storage.read('api_name') ?? '';
    email.value = _storage.read('api_email') ?? '';
    phone.value = _storage.read('api_phone') ?? '';
    avatarUrl.value = _storage.read('api_avatarUrl') ?? '';
    isLoggedIn.value = token.value != null && token.value!.isNotEmpty;
  }

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
      debugPrint('[ApiAuth] login error: $msg');
      return false;
    }
  }

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
      debugPrint('[ApiAuth] register error: $msg');
      return false;
    }
  }

  Future<void> signOut() async {
    token.value = null;
    isLoggedIn.value = false;
    lastError.value = '';
    _storage.remove('api_token');
    _storage.remove('api_userId');
    _storage.remove('api_name');
    _storage.remove('api_email');
    _storage.remove('api_role');
    _storage.remove('api_phone');
    _storage.remove('api_avatarUrl');
  }

  Future<bool> refreshProfile() async {
    final t = token.value;
    if (t == null) return false;
    try {
      final me = await UserRepository.instance.getMe(t);
      name.value = (me['name'] ?? '').toString();
      email.value = (me['email'] ?? '').toString();
      phone.value = (me['phone'] ?? '').toString();
      avatarUrl.value = (me['avatarUrl'] ?? '').toString();
      _storage.write('api_name', name.value);
      _storage.write('api_email', email.value);
      _storage.write('api_phone', phone.value);
      _storage.write('api_avatarUrl', avatarUrl.value);
      return true;
    } catch (e) {
      debugPrint('[ApiAuth] refresh profile error: $e');
      return false;
    }
  }

  Future<bool> updateProfile({String? newName, String? newPhone, String? newAvatarUrl}) async {
    final t = token.value;
    if (t == null) return false;
    try {
      final res = await UserRepository.instance.updateMe(t, name: newName, phone: newPhone, avatarUrl: newAvatarUrl);
      name.value = (res['name'] ?? name.value).toString();
      phone.value = (res['phone'] ?? phone.value).toString();
      avatarUrl.value = (res['avatarUrl'] ?? avatarUrl.value).toString();
      _storage.write('api_name', name.value);
      _storage.write('api_phone', phone.value);
      _storage.write('api_avatarUrl', avatarUrl.value);
      return true;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      lastError.value = msg;
      debugPrint('[ApiAuth] update profile error: $msg');
      return false;
    }
  }
}
