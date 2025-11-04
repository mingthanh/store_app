import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Controller quản lý theme sáng/tối cho toàn bộ ứng dụng
/// - Lưu trạng thái vào GetStorage để giữ lựa chọn của người dùng
class ThemeController extends GetxController {
  final _box = GetStorage();

  final _key = 'isDarkMode';

  /// Trả về ThemeMode hiện tại dựa vào cờ isDarkMode trong storage
  ThemeMode get theme => _loadTheme() ? ThemeMode.dark : ThemeMode.light;
  /// true nếu đang ở chế độ Dark
  bool get isDarkMode => _loadTheme();

  /// Đọc cờ từ storage, mặc định false (Light)
  bool _loadTheme()=> _box.read(_key) ?? false;

  /// Lưu cờ isDarkMode vào storage
  void saveTheme(bool isDarkMode) => _box.write(_key, isDarkMode);

  /// Đảo trạng thái theme và áp dụng ngay qua Get.changeThemeMode
  void toggleTheme(){
    Future.delayed(const Duration(milliseconds: 50), () {
      Get.changeThemeMode(_loadTheme() ? ThemeMode.light : ThemeMode.dark);
      saveTheme(!_loadTheme());
      update();
    });
  }
}