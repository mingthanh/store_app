import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:store_app/controllers/navigation_controller.dart';
import 'package:store_app/services/firestore_service.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:firebase_core/firebase_core.dart';
// Google Sign-In removed

class AuthController extends GetxController {
  final _storage = GetStorage();

  final RxBool isFirstTime = true.obs;
  final RxBool isLoggedIn = false.obs;

  // ignore: unused_element
  bool get _isFirstTime => isFirstTime.value;
  // ignore: unused_element
  bool get _isLoggedIn => isLoggedIn.value;

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
    // Reset navigation to Home tab on login
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().changeIndex(0);
    }
    isLoggedIn.value = true;
    _storage.write('isLoggedIn', true);
  }

  void logout() {
    // Reset navigation to Home tab on logout
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().changeIndex(0);
    }
    isLoggedIn.value = false;
    _storage.write('isLoggedIn', false);
    // attempt to log out from Facebook as well (ignore errors)
    FacebookAuth.instance.logOut().catchError((_) {});
    // Google Sign-In removed: no Google sign-out
    // clear cached social data
    _storage.remove('fbUser');
    _storage.remove('fbToken');
    // _storage.remove('googleUser'); // removed: no Google data used
  }

  /// Facebook Login flow
  /// Returns true when successfully logged in, false otherwise
  Future<bool> loginWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;
        if (accessToken == null) {
          return false;
        }

        // Optionally fetch user data
        final userData = await FacebookAuth.instance.getUserData(
          fields: 'id,name,email,picture.width(200)',
        );
        // You can store userData if needed, or send token to your backend.
        try {
          // Ensure Firebase is initialized before Firestore usage
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
          } else {
            debugPrint('[Auth] Missing Facebook id in userData, skip upsert');
          }
        } catch (e) {
          _storage.write('firestoreLastError', e.toString());
          debugPrint('[Auth] Firestore upsert error: ${e.toString()}');
        }

        // Reset navigation to Home tab on successful login
        if (Get.isRegistered<NavigationController>()) {
          Get.find<NavigationController>().changeIndex(0);
        }
        isLoggedIn.value = true;
        _storage.write('isLoggedIn', true);
        _storage.write('fbUser', userData);
        _storage.write('fbToken', accessToken.tokenString);
        return true;
      } else {
        // cancelled or failed
        return false;
      }
    } catch (e) {
      // log error and return false
      return false;
    }
  }

  // Google Sign-In removed on request
}
