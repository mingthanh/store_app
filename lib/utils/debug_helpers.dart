import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_app/controllers/auth_controller.dart';

class DebugHelpers {
  /// Reset app về trạng thái ban đầu (để test)
  static void resetAppToFirstTime() {
    final storage = GetStorage();
    
    // Xóa tất cả dữ liệu stored
    storage.erase();
    
    // Reset AuthController
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      authController.isFirstTime.value = true;
      authController.isLoggedIn.value = false;
      authController.userId.value = null;
      authController.role.value = 'user';
    }
    
    // ignore: avoid_print
    print('✅ App đã được reset về trạng thái ban đầu');
  }
  
  /// Kiểm tra trạng thái hiện tại
  static void checkCurrentState() {
    final storage = GetStorage();
    final isFirstTime = storage.read('isFirstTime') ?? true;
    final isLoggedIn = storage.read('isLoggedIn') ?? false;
    
    // ignore: avoid_print
    print('📱 Trạng thái hiện tại:');
    // ignore: avoid_print
    print('   - Lần đầu: $isFirstTime');
    // ignore: avoid_print
    print('   - Đã đăng nhập: $isLoggedIn');
    
    if (Get.isRegistered<AuthController>()) {
      final auth = Get.find<AuthController>();
      // ignore: avoid_print
      print('   - AuthController isFirstTime: ${auth.isFirstTime.value}');
      // ignore: avoid_print
      print('   - AuthController isLoggedIn: ${auth.isLoggedIn.value}');
    }
  }
}