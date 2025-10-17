import 'package:store_app/controllers/auth_controller.dart';
import 'package:store_app/controllers/theme_controller.dart';
import 'package:store_app/utils/app_themes.dart';
import 'package:store_app/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'controllers/navigation_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'utils/app_secrets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:store_app/services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  // Initialize Firebase for non-web (Android/iOS/macOS/Windows)
  try {
    if (!kIsWeb) {
      await Firebase.initializeApp();
      // mark initialized for quick verification
      final box = GetStorage();
      await box.write('firebaseReady', true);
      await box.remove('firebaseInitError');
      // optional log
      // ignore: avoid_print
      print('[Firebase] initialized successfully');

      // Optional: seed sample products once (dev only)
      try {
        final seeded = await FirestoreService.instance
            .seedSampleProductsIfEmpty();
        if (seeded > 0) {
          // ignore: avoid_print
          print('[Firestore] Seeded $seeded sample products');
        }
      } catch (e) {
        // ignore: avoid_print
        print('[Firestore] Seed products error: ${e.toString()}');
      }
    }
  } catch (e) {
    // Safe-guard: ignore init errors here; typically missing config files.
    final box = GetStorage();
    await box.write('firebaseReady', false);
    await box.write('firebaseInitError', e.toString());
    // ignore: avoid_print
    print('[Firebase] initialization error: ${e.toString()}');
  }
  // Initialize Facebook SDK for Web
  if (kIsWeb) {
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: AppSecrets.facebookAppId,
      cookie: true,
      xfbml: true,
      version: AppSecrets.facebookWebSdkVersion,
    );
  }
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(NavigationController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Store',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeController.theme,
      defaultTransition: Transition.fade,
      home: SplashScreen(),
    );
  }
}
