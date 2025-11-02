import 'package:store_app/controllers/api_auth_controller.dart';
import 'package:store_app/controllers/auth_controller.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:store_app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:get/get.dart';
import 'main_screen.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';

class SigninScreen extends StatelessWidget {
  SigninScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isMobilePlatform =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final bool facebookSupported = kIsWeb ? false : isMobilePlatform;
    final bool googleSupported = kIsWeb || isMobilePlatform;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Welcome Back',
                style: AppTextStyles.withColor(
                  AppTextStyles.h1,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue shopping',
                style: AppTextStyles.withColor(
                  AppTextStyles.bodyLarge,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
              const SizedBox(height: 40),

              /// ==========================
              /// Form Login
              /// ==========================
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // email textfield
                    CustomTextfield(
                      label: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!GetUtils.isEmail(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // password textfield
                    CustomTextfield(
                      label: 'Password',
                      prefixIcon: Icons.lock_outline,
                      keyboardType: TextInputType.visiblePassword,
                      isPassword: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (!GetUtils.isLengthGreaterThan(value, 6)) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Handle forgot password
                    Get.to(() => ForgotPasswordScreen());
                  },
                  child: Text(
                    'Forgot Password?',
                    style: AppTextStyles.withColor(
                      AppTextStyles.buttonMedium,
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // sign in button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: handleSignIn, // Gọi hàm khi bấm nút
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Sign In',
                    style: AppTextStyles.withColor(
                      AppTextStyles.buttonMedium,
                      Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Or divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                ],
              ),
              const SizedBox(height: 16),

              // Facebook login button (brand style)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.facebook, color: Colors.white),
                  label: Text(
                    // ignore: prefer_interpolation_to_compose_strings
                    'Continue with Facebook' +
                        (facebookSupported ? '' : ' (Android/iOS only)'),
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (!facebookSupported) {
                      Get.snackbar(
                        'Not supported',
                        'Facebook login isn\'t available on this platform. Please use an Android/iOS device.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    final fbAuth = Get.find<AuthController>();
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );
                    final ok = await fbAuth.loginWithFacebook();
                    Get.back();
                    if (ok) {
                      final auth = Get.find<AuthController>();
                      if (auth.role.value == 'admin') {
                        Get.offAllNamed('/admin');
                      } else {
                        Get.offAll(() => const MainScreen());
                      }
                    } else {
                      final auth = Get.find<AuthController>();
                      Get.snackbar(
                        'Login failed',
                        auth.lastError.value.isNotEmpty ? auth.lastError.value : 'Could not sign in with Facebook',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Google login button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.g_mobiledata, color: Color(0xFFDB4437), size: 28),
                  label: Text(
                    // ignore: prefer_interpolation_to_compose_strings
                    'Continue with Google' + (googleSupported ? '' : ' (Android/iOS/Web only)'),
                    style: AppTextStyles.buttonMedium,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        // ignore: deprecated_member_use
                        ? Colors.white.withOpacity(0.06)
                        : Colors.white,
                  ),
                  onPressed: () async {
                    if (!googleSupported) {
                      Get.snackbar(
                        'Not supported',
                        'Google sign-in isn\'t available on this platform. Please use Android/iOS or run Web (Chrome).',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    final auth = Get.find<AuthController>();
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );
                    final ok = await auth.loginWithGoogle();
                    Get.back();
                    if (ok) {
                      final a = Get.find<AuthController>();
                      if (a.role.value == 'admin') {
                        Get.offAllNamed('/admin');
                      } else {
                        Get.offAll(() => const MainScreen());
                      }
                    } else {
                      final a = Get.find<AuthController>();
                      Get.snackbar(
                        'Login failed',
                        a.lastError.value.isNotEmpty ? a.lastError.value : 'Could not sign in with Google',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),
              // signup textbutton
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppTextStyles.withColor(
                      AppTextStyles.bodyMedium,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => SignUpScreen()),
                    child: Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleSignIn() {
  final ApiAuthController authController = Get.find<ApiAuthController>();
    if (!_formKey.currentState!.validate()) return;

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    authController
        .signInWithEmail(_emailController.text.trim(), _passwordController.text.trim())
        .then((ok) {
      Get.back();
      if (ok) {
        if (authController.isAdmin) {
          Get.offAllNamed('/admin');
        } else {
          Get.offAll(() => const MainScreen());
        }
      } else {
        final msg = authController.lastError.value.isNotEmpty
            ? authController.lastError.value
            : 'Invalid credentials';
        Get.snackbar('Login failed', msg, snackPosition: SnackPosition.BOTTOM);
      }
    }
    );
  }
}
