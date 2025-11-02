import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:store_app/controllers/api_auth_controller.dart';

/// Tiện ích kiểm tra quyền mua sắm của người dùng
/// Chỉ cho phép user đăng nhập bằng email/password mua hàng
class ShoppingUtils {
  /// Kiểm tra xem user có thể thêm vào giỏ hàng không
  /// Chỉ user đăng nhập bằng email/password mới được phép
  static bool canAddToCart() {
    try {
      final auth = Get.find<ApiAuthController>();
      return auth.isLoggedIn.value && !auth.isSocialLogin.value;
    } catch (e) {
      return false; // Không có auth controller nghĩa là chưa đăng nhập
    }
  }

  /// Hiển thị thông báo hạn chế cho user đăng nhập social
  static void showSocialLoginRestriction() {
    Get.snackbar(
      'Không thể mua hàng',
      'Tính năng mua sắm chỉ dành cho tài khoản email/password. Vui lòng tạo tài khoản bằng email và mật khẩu.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  /// Hiển thị thông báo yêu cầu đăng nhập
  static void showLoginRequired() {
    Get.snackbar(
      'Cần đăng nhập',
      'Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Kiểm tra quyền mua sắm và hiển thị thông báo phù hợp
  /// Return true nếu được phép mua sắm, false nếu không
  static bool checkShoppingPermission() {
    try {
      final auth = Get.find<ApiAuthController>();
      
      // Kiểm tra đã đăng nhập chưa
      if (!auth.isLoggedIn.value) {
        showLoginRequired();
        return false;
      }
      
      // Kiểm tra có phải social login không
      if (auth.isSocialLogin.value) {
        showSocialLoginRestriction();
        return false;
      }
      
      return true; // Email/password user - có quyền mua sắp
    } catch (e) {
      showLoginRequired();
      return false;
    }
  }
}