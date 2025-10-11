import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final _storage = GetStorage();

  final RxBool isFirstTime = true.obs;
  final RxBool isLoggedIn = false.obs;

  // ignore: unused_element
  bool get _isFirstTime => isFirstTime.value;
  // ignore: unused_element
  bool get _isLoggedIn => isLoggedIn.value;

  @override
  void onInit() {
    super.onInit();
    _loadInitialAuthState();
  }

  void _loadInitialAuthState() {
    isFirstTime.value = _storage.read('isFirstTime') ?? true;
    isLoggedIn.value = _storage.read('isLoggedIn') ?? false;
  }

  void setFirstTimeDone() {
    isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }

  void login(){
    isLoggedIn.value = true;
    _storage.write('isLoggedIn', true);
  }

  void logout(){
    isLoggedIn.value = false;
    _storage.write('isLoggedIn', false);
  }
}