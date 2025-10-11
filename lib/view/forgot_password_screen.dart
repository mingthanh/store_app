import 'package:store_app/utils/app_textstyles.dart';
import 'package:store_app/view/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios),
                color: isDark ? Colors.white : Colors.black,
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Reset Password',
                style: AppTextStyles.withColor(
                  AppTextStyles.h1,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Enter your email to reset your password',
                style: AppTextStyles.withColor(
                  AppTextStyles.bodyLarge,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),

              const SizedBox(height: 40),

              // Email textfield
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

              const SizedBox(height: 24),

              // Send reset link button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // handle send reset link
                    showSuccessDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Send Reset Link',
                    style: AppTextStyles.withColor(
                      AppTextStyles.buttonMedium,
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Show success dialog
  void showSuccessDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Check your email',
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
        content: Text(
          'We have sent a password reset link to your email.',
          style: AppTextStyles.withColor(
            AppTextStyles.bodyLarge,
            Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'OK',
              style: AppTextStyles.withColor(
                AppTextStyles.buttonMedium,
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
