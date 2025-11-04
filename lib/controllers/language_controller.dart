import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Controller quản lý ngôn ngữ ứng dụng (i18n)
/// - Lưu languageCode vào GetStorage để ghi nhớ sau khi mở lại app
/// - Cập nhật locale toàn app qua Get.updateLocale
class LanguageController extends GetxController {
  static const _key = 'languageCode';
  final GetStorage _box = GetStorage();

  late Rx<Locale> _locale;

  /// Locale hiện tại của app
  Locale get locale => _locale.value;

  @override
  void onInit() {
    super.onInit();
    final code = _box.read<String>(_key) ?? 'en';
    _locale = Rx<Locale>(_toLocale(code));
  }

  /// Đặt ngôn ngữ theo [code] (ví dụ: 'en' hoặc 'vi')
  /// - Lưu xuống local storage
  /// - Cập nhật UI ngay bằng Get.updateLocale
  void setLanguage(String code) {
    final loc = _toLocale(code);
    _locale.value = loc;
    _box.write(_key, code);
    Get.updateLocale(loc);
    update();
  }

  /// Chuyển đổi nhanh giữa tiếng Anh và tiếng Việt
  void toggleLanguage() {
    setLanguage(locale.languageCode == 'en' ? 'vi' : 'en');
  }

  /// Chuyển string code → Locale
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
