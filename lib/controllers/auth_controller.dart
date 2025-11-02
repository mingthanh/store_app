// Import các thư viện cần thiết
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:store_app/controllers/navigation_controller.dart';
import 'package:store_app/controllers/cart_controller.dart';
import 'package:store_app/controllers/wishlist_controller.dart';
import 'package:store_app/services/firestore_service.dart';
import 'package:store_app/services/auth_service.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:store_app/controllers/api_auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Controller quản lý xác thực người dùng với Firebase Auth
/// Hỗ trợ đăng nhập bằng Email/Password, Facebook và Google
class AuthController extends GetxController {
  final _storage = GetStorage();

  // Các trạng thái reactive của người dùng
  final RxBool isFirstTime = true.obs;    // Lần đầu mở app
  final RxBool isLoggedIn = false.obs;    // Đã đăng nhập
  final RxString role = 'user'.obs;       // Vai trò (user/admin)
  final RxnString userId = RxnString();   // ID người dùng
  final RxString lastError = ''.obs;      // Lỗi cuối cùng

  @override
  void onInit() {
    super.onInit();
    _loadInitialAuthState();              // Tải trạng thái xác thực ban đầu
    _ensureCartWishlistControllers();     // Đảm bảo controllers được khởi tạo
  }

  /// Tải trạng thái xác thực ban đầu từ storage
  void _loadInitialAuthState() {
    isFirstTime.value = _storage.read('isFirstTime') ?? true;
    isLoggedIn.value = _storage.read('isLoggedIn') ?? false;
  }

  /// Đảm bảo CartController và WishlistController được khởi tạo
  void _ensureCartWishlistControllers() {
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController());
    }
    if (!Get.isRegistered<WishlistController>()) {
      Get.put(WishlistController());
    }
  }

  /// Đánh dấu đã hoàn thành lần đầu mở app
  void setFirstTimeDone() {
    isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }

  /// Đăng nhập cục bộ (legacy, giữ để tương thích)
  void login() {
    // Chuyển về tab Home sau khi đăng nhập
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
      _loadUserData(cred.user?.uid); // Load cart/wishlist for this user
      isLoggedIn.value = true;
      _storage.write('isLoggedIn', true);
      
      // Đánh dấu đã hoàn thành onboarding khi đăng nhập thành công
      setFirstTimeDone();
      
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
      _loadUserData(cred.user?.uid); // Load cart/wishlist for this user
      isLoggedIn.value = true;
      _storage.write('isLoggedIn', true);
      
      // Đánh dấu đã hoàn thành onboarding khi đăng ký thành công
      setFirstTimeDone();
      
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
    // Clear user-specific data first
    _clearUserData();
    
    // Reset navigation về tab Home
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().changeIndex(0);
    }

    // Xoá trạng thái đăng nhập cục bộ
    isLoggedIn.value = false;
    _storage.write('isLoggedIn', false);
    
    // KHÔNG reset isFirstTime - giữ nguyên để không hiện onboarding khi đăng xuất
    // isFirstTime.value = true;
    // _storage.write('isFirstTime', true);

    // Thoát tài khoản Facebook (nếu có)
    FacebookAuth.instance.logOut().catchError((_) {});

    // Xoá cache Facebook
    _storage.remove('fbUser');
    _storage.remove('fbToken');
  }

  /// Load cart và wishlist cho user hiện tại
  void _loadUserData(String? userId) {
    if (userId == null || userId.isEmpty) return;
    
    try {
      // Load cart data for this user
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().loadUserCart(userId);
      }
      
      // Load wishlist data for this user
      if (Get.isRegistered<WishlistController>()) {
        Get.find<WishlistController>().loadUserWishlist(userId);
      }
      
      debugPrint('[Auth] Loaded user data for: $userId');
    } catch (e) {
      debugPrint('[Auth] Error loading user data: $e');
    }
  }

  /// Clear cart và wishlist khi logout
  void _clearUserData() {
    try {
      // Clear cart data
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().clearUserData();
      }
      
      // Clear wishlist data
      if (Get.isRegistered<WishlistController>()) {
        Get.find<WishlistController>().clearUserData();
      }
      
      debugPrint('[Auth] Cleared user data');
    } catch (e) {
      debugPrint('[Auth] Error clearing user data: $e');
    }
  }

  /// Facebook Login flow via FirebaseAuth
  Future<bool> loginWithFacebook() async {
    try {
      // Guard: Facebook login not supported on desktop targets
      if (!kIsWeb &&
          !(defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        lastError.value = 'unsupported_platform: Facebook login only works on Android/iOS (or Web with extra setup).';
        // ignore: prefer_interpolation_to_compose_strings
        debugPrint('[Auth] Facebook login blocked on unsupported platform: ' +
            defaultTargetPlatform.toString());
        return false;
      }
      lastError.value = '';
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success || result.accessToken == null) {
        lastError.value = 'facebook_login_failed';
        return false;
      }

      // Exchange FB access token for Firebase credential
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);
      final UserCredential cred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = cred.user;
      if (user == null) return false;

      // Try to fetch extra profile data from FB for photo/name/email
      Map<String, dynamic>? fbData;
      try {
        fbData = await FacebookAuth.instance.getUserData(
          fields: 'id,name,email,picture.width(200)'
        );
      } catch (_) {}

      userId.value = user.uid;
      _loadUserData(user.uid); // Load cart/wishlist for this user
      // Upsert Firestore user profile with Firebase uid
      try {
        final isAdmin = (user.email ?? '').toLowerCase().startsWith('admin0411@');
        await FirestoreService.instance.upsertUserProfile(
          userId: user.uid,
          name: user.displayName ?? (fbData?['name']?.toString() ?? ''),
          email: user.email ?? (fbData?['email']?.toString() ?? ''),
          photoUrl: user.photoURL ?? (fbData?['picture']?['data']?['url'] as String?),
          extra: {
            'provider': 'facebook',
            if (isAdmin) 'role': 'admin',
          },
        );
        final doc = await FirestoreService.instance.users.doc(user.uid).get();
        role.value = (doc.data()?['role'] as String?) ?? (isAdmin ? 'admin' : 'user');
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
      
      // Đánh dấu đã hoàn thành onboarding khi đăng nhập Facebook thành công
      setFirstTimeDone();
      
      if (fbData != null) _storage.write('fbUser', fbData);
      _storage.write('fbToken', result.accessToken!.tokenString);

      // Sync to ApiAuthController so AccountScreen reflects profile
      if (Get.isRegistered<ApiAuthController>()) {
        try {
          Get.find<ApiAuthController>().setSocialProfile(
            firebaseUserId: user.uid,
            displayName: user.displayName ?? (fbData?['name']?.toString()),
            emailAddress: user.email ?? (fbData?['email']?.toString()),
            avatar: user.photoURL ?? (fbData?['picture']?['data']?['url'] as String?),
            roleString: role.value,
          );
        } catch (e) {
          debugPrint('[Auth] Sync to ApiAuthController failed: $e');
        }
      }

      return true;
    } on FirebaseAuthException catch (e) {
      lastError.value = e.code;
      debugPrint('[Auth] Facebook login error: ${e.code}');
      return false;
    } catch (e) {
      lastError.value = e.toString();
      debugPrint('[Auth] Facebook login error: $e');
      return false;
    }
  }

  /// Google Sign-In flow (Web + Mobile)
  Future<bool> loginWithGoogle() async {
    try {
      // Guard: Google sign-in only on Web or Android/iOS
      if (!kIsWeb &&
          !(defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        lastError.value = 'unsupported_platform: Google sign-in only works on Android/iOS or Web.';
        // ignore: prefer_interpolation_to_compose_strings
        debugPrint('[Auth] Google login blocked on unsupported platform: ' +
            defaultTargetPlatform.toString());
        return false;
      }
      lastError.value = '';
      User? firebaseUser;

      if (kIsWeb) {
        // Web: Use popup to avoid sessionStorage issues
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.setCustomParameters({'prompt': 'select_account'});
        final cred = await FirebaseAuth.instance.signInWithPopup(provider);
        firebaseUser = cred.user;
      } else {
        // Mobile: Fallback to simpler approach without sessionStorage issues
        try {
          final provider = GoogleAuthProvider();
          provider.addScope('email');
          // Remove problematic custom parameters that can cause storage issues
          
          final cred = await FirebaseAuth.instance.signInWithProvider(provider);
          firebaseUser = cred.user;
        } catch (e) {
          debugPrint('[Auth] Google mobile sign-in error: $e');
          // If signInWithProvider fails, try alternative approach
          lastError.value = 'google_signin_error: Please ensure you have added SHA-1/SHA-256 fingerprints to Firebase Console';
          return false;
        }
      }

      final user = firebaseUser;
      if (user == null) return false;

      userId.value = user.uid;
      _loadUserData(user.uid); // Load cart/wishlist for this user
      // Upsert user profile to Firestore
      try {
        final isAdmin = (user.email ?? '').toLowerCase().startsWith('admin0411@');
        await FirestoreService.instance.upsertUserProfile(
          userId: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          extra: {
            'provider': 'google',
            if (isAdmin) 'role': 'admin',
          },
        );
        // read role back (best-effort)
        final doc = await FirestoreService.instance.users.doc(user.uid).get();
        role.value = (doc.data()?['role'] as String?) ?? (isAdmin ? 'admin' : 'user');
      } catch (e) {
        debugPrint('[Auth] Firestore upsert (google) error: $e');
      }

      // Update local state + navigate
      isLoggedIn.value = true;
      _storage.write('isLoggedIn', true);
      
      // Đánh dấu đã hoàn thành onboarding khi đăng nhập Google thành công
      setFirstTimeDone();
      
      if (Get.isRegistered<NavigationController>()) {
        Get.find<NavigationController>().changeIndex(0);
      }

      // Sync to ApiAuthController so AccountScreen reflects profile
      if (Get.isRegistered<ApiAuthController>()) {
        try {
          Get.find<ApiAuthController>().setSocialProfile(
            firebaseUserId: user.uid,
            displayName: user.displayName,
            emailAddress: user.email,
            avatar: user.photoURL,
            roleString: role.value,
          );
        } catch (e) {
          debugPrint('[Auth] Sync to ApiAuthController failed: $e');
        }
      }
      return true;
    } on FirebaseAuthException catch (e) {
      lastError.value = e.code;
      debugPrint('[Auth] Google login error: ${e.code}');
      return false;
    } catch (e) {
      lastError.value = e.toString();
      debugPrint('[Auth] Google login error: $e');
      return false;
    }
  }
}