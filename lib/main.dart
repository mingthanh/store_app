import 'package:store_app/controllers/auth_controller.dart';
import 'package:store_app/controllers/theme_controller.dart';
import 'package:store_app/controllers/wishlist_controller.dart';
import 'package:store_app/utils/app_themes.dart';
import 'package:store_app/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'utils/translations.dart';
import 'controllers/navigation_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'utils/app_secrets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:store_app/services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // ✅ Khởi tạo các controller càng sớm càng tốt
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(NavigationController());
  Get.put(WishlistController()); // ✅ Controller này cần sớm có mặt

  // ✅ Khởi tạo Firebase (nếu cần)
  try {
    if (!kIsWeb) {
  await Firebase.initializeApp();
      final box = GetStorage();
      await box.write('firebaseReady', true);
      await box.remove('firebaseInitError');
  debugPrint('[Firebase] initialized successfully');

      // seed sample products
      try {
        final seeded = await FirestoreService.instance.seedSampleProductsIfEmpty();
        if (seeded > 0) {
          debugPrint('[Firestore] Seeded $seeded sample products');
        }
      } catch (e) {
        debugPrint('[Firestore] Seed products error: ${e.toString()}');
      }
    }
  } catch (e) {
    final box = GetStorage();
    await box.write('firebaseReady', false);
    await box.write('firebaseInitError', e.toString());
    debugPrint('[Firebase] initialization error: ${e.toString()}');
  }

  // ✅ Facebook SDK Web
  if (kIsWeb) {
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: AppSecrets.facebookAppId,
      cookie: true,
      xfbml: true,
      version: AppSecrets.facebookWebSdkVersion,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final box = GetStorage();
    final savedLocale = box.read('locale') as String?;
    final locale = savedLocale != null ? Locale(savedLocale.split('_')[0], savedLocale.split('_')[1]) : null;
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Store',
      translations: AppTranslations(),
      locale: locale,
      fallbackLocale: const Locale('en', 'US'),
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeController.theme,
      defaultTransition: Transition.fade,
      home: SplashScreen(),
    );
  }
}