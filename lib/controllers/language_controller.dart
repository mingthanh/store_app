import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  static const _key = 'languageCode';
  final GetStorage _box = GetStorage();

  late Rx<Locale> _locale;

  Locale get locale => _locale.value;

  @override
  void onInit() {
    super.onInit();
    final code = _box.read<String>(_key) ?? 'en';
    _locale = Rx<Locale>(_toLocale(code));
  }

  void setLanguage(String code) {
    final loc = _toLocale(code);
    _locale.value = loc;
    _box.write(_key, code);
    Get.updateLocale(loc);
    update();
  }

  void toggleLanguage() {
    setLanguage(locale.languageCode == 'en' ? 'vi' : 'en');
  }

  Locale _toLocale(String code) {
    switch (code) {
      case 'vi':
        return const Locale('vi', 'VN');
      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }
}
