import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:store_app/controllers/navigation_controller.dart';
import 'package:store_app/services/firestore_service.dart';
import 'package:store_app/services/auth_service.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Google Sign-In removed

class AuthController extends GetxController {
  final _storage = GetStorage();

  final RxBool isFirstTime = true.obs;
  final RxBool isLoggedIn = false.obs;
  final RxString role = 'user'.obs;
  final RxnString userId = RxnString();

  // Removed unused private getters to satisfy analyzer

  @override
  void onInit() {
    super.onInit();
    _loadInitialAuthState();
  }

  void _loadInitialAuthState() {
    isFirstTime.value = _storage.read('isFirstTime') ?? true;
    isLoggedIn.value = _storage.read('isLoggedIn') ?? false;
  }

  void setFirstTimeDone() {
    isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }

  void login() {
    // Legacy local login kept for compatibility
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().changeIndex(0);
    }
    isLoggedIn.value = true;
    _storage.write('isLoggedIn', true);
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      final cred = await AuthService.instance.signIn(email: email, password: password);
      userId.value = cred.user?.uid;
      isLoggedIn.value = true;
      _storage.write('isLoggedIn', true);
      // read role from user doc (best-effort)
      final doc = await FirestoreService.instance.users.doc(userId.value).get();
      final r = (doc.data()?['role'] as String?) ?? 'user';
      role.value = r;
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('[Auth] signIn error: ${e.code}');
      return false;
    }
  }

  Future<bool> signUpWithEmail(String name, String email, String password) async {
    try {
      final cred = await AuthService.instance.signUp(name: name, email: email, password: password);
      userId.value = cred.user?.uid;
      isLoggedIn.value = true;
      _storage.write('isLoggedIn', true);
      final doc = await FirestoreService.instance.users.doc(userId.value).get();
      final r = (doc.data()?['role'] as String?) ?? 'user';
      role.value = r;
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('[Auth] signUp error: ${e.code}');
      return false;
    }
  }

  Future<void> signOut() async {
    await AuthService.instance.signOut();
    logout();
  }

  /// ✅ ĐÂY LÀ HÀM LOGOUT CHUẨN
  void logout() {
    // Reset navigation về tab Home
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().changeIndex(0);
    }

    // Xoá trạng thái đăng nhập cục bộ
    isLoggedIn.value = false;
    _storage.write('isLoggedIn', false);

    // Thoát tài khoản Facebook (nếu có)
    FacebookAuth.instance.logOut().catchError((_) {});

    // Xoá cache Facebook
    _storage.remove('fbUser');
    _storage.remove('fbToken');
  }

  /// Facebook Login flow
  Future<bool> loginWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        if (accessToken == null) return false;

        final userData = await FacebookAuth.instance.getUserData(
          fields: 'id,name,email,picture.width(200)',
        );

        try {
          if (Firebase.apps.isEmpty) {
            await Firebase.initializeApp();
          }
          final id = userData['id']?.toString() ?? '';
          final name = userData['name']?.toString() ?? '';
          final email = userData['email']?.toString() ?? '';
          final photo = (userData['picture']?['data']?['url'] as String?);
          if (id.isNotEmpty) {
            debugPrint('[Auth] Upserting Firestore user $id ...');
            await FirestoreService.instance.upsertUserProfile(
              userId: id,
              name: name,
              email: email,
              photoUrl: photo,
              extra: {'provider': 'facebook'},
            );
            debugPrint('[Auth] Firestore upsert completed for $id');
          }
        } catch (e) {
          _storage.write('firestoreLastError', e.toString());
          debugPrint('[Auth] Firestore upsert error: ${e.toString()}');
        }

        // Cập nhật trạng thái đăng nhập
        if (Get.isRegistered<NavigationController>()) {
          Get.find<NavigationController>().changeIndex(0);
        }
        isLoggedIn.value = true;
        _storage.write('isLoggedIn', true);
        _storage.write('fbUser', userData);
        _storage.write('fbToken', accessToken.tokenString);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('[Auth] Facebook login error: $e');
      return false;
    }
  }
}