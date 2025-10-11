import 'package:store_app/controllers/auth_controller.dart';
import 'package:store_app/controllers/theme_controller.dart';
import 'package:store_app/utils/app_themes.dart';
import 'package:store_app/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'controllers/navigation_controller.dart';

void main() async {
  await GetStorage.init();
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