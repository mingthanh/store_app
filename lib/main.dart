// Import các controller và service cần thiết
import 'package:store_app/controllers/auth_controller.dart';
import 'package:store_app/controllers/api_auth_controller.dart';
import 'package:store_app/controllers/theme_controller.dart';
import 'package:store_app/controllers/language_controller.dart';
import 'package:store_app/controllers/wishlist_controller.dart';
import 'package:store_app/utils/app_themes.dart';
import 'package:store_app/utils/translations.dart';
import 'package:store_app/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'controllers/navigation_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'utils/app_secrets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:store_app/services/firestore_service.dart';
import 'package:store_app/view/admin_dashboard_api_screen.dart';
import 'package:store_app/view/admin_account_screen.dart';
import 'firebase_options.dart';

/// Hàm main - điểm khởi đầu của ứng dụng
Future<void> main() async {
  // Đảm bảo Flutter engine đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo GetStorage để lưu trữ dữ liệu local
  await GetStorage.init();

  // Khởi tạo các controller toàn cục với GetX
  Get.put(ThemeController());     // Quản lý giao diện sáng/tối
  Get.put(LanguageController());  // Quản lý ngôn ngữ
  Get.put(ApiAuthController());   // Xác thực qua API
  Get.put(AuthController());      // Xác thực Firebase
  Get.put(NavigationController()); // Điều hướng bottom navigation
  Get.put(WishlistController());   // Quản lý danh sách yêu thích

  // Khởi tạo Firebase để kết nối với backend
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final box = GetStorage();
    await box.write('firebaseReady', true);
    await box.remove('firebaseInitError');
    debugPrint('[Firebase] initialized successfully');

    // Tạo dữ liệu mẫu sản phẩm nếu chưa có
    try {
      final seeded = await FirestoreService.instance.seedSampleProductsIfEmpty();
      if (seeded > 0) {
        debugPrint('[Firestore] Seeded $seeded sample products');
      }
    } catch (e) {
      debugPrint('[Firestore] Seed products error: ${e.toString()}');
    }
  } catch (e) {
    final box = GetStorage();
    await box.write('firebaseReady', false);
    await box.write('firebaseInitError', e.toString());
    debugPrint('[Firebase] initialization error: ${e.toString()}');
  }

  // Khởi tạo Facebook SDK cho Web platform
  if (kIsWeb) {
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: AppSecrets.facebookAppId,
      cookie: true,
      xfbml: true,
      version: AppSecrets.facebookWebSdkVersion,
    );
  }

  // Chạy ứng dụng chính
  runApp(const MyApp());
}

/// Widget ứng dụng chính
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy các controller đã khởi tạo từ GetX
    final themeController = Get.find<ThemeController>();
    final languageController = Get.find<LanguageController>();
    
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Store',
      translations: AppTranslations(),           // Đa ngôn ngữ
      locale: languageController.locale,         // Ngôn ngữ hiện tại
      fallbackLocale: const Locale('en', 'US'),  // Ngôn ngữ dự phòng
      theme: AppThemes.light,                    // Giao diện sáng
      darkTheme: AppThemes.dark,                 // Giao diện tối
      themeMode: themeController.theme,          // Chế độ giao diện
      defaultTransition: Transition.fade,       // Hiệu ứng chuyển màn hình
      
      // Định nghĩa các route cho admin
      getPages: [
        GetPage(name: '/admin', page: () => const AdminDashboardApiScreen()),
        GetPage(name: '/admin-account', page: () => const AdminAccountScreen()),
      ],
      
      // Màn hình khởi đầu
      home: SplashScreen(),
    );
  }
}