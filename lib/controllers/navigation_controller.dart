import 'package:get/get.dart';

  /// Controller điều hướng đơn giản cho BottomNavigationBar
  /// - currentIndex: tab hiện tại (0 = Home, 1 = ...)
class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  /// Đổi tab đang hiển thị
  /// [index] là vị trí tab trong BottomNavigationBar
  void changeIndex(int index) {
    currentIndex.value = index;
  }
}