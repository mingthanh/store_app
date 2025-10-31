import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/widgets/custom_textfield.dart';

class ProfileForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  const ProfileForm({super.key, required this.nameController, required this.phoneController, required this.emailController});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildFieldWrapper(
            context,
            CustomTextfield(
              label: 'full_name'.tr,
              prefixIcon: Icons.person_outline,
              controller: nameController,
            ),
            isDark,
          ),
          const SizedBox(height: 16),
          _buildFieldWrapper(
            context,
            CustomTextfield(
              label: 'phone_number'.tr,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              controller: phoneController,
            ),
            isDark,
          ),
          const SizedBox(height: 16),
          _buildFieldWrapper(
            context,
            CustomTextfield(
              label: 'email'.tr,
              prefixIcon: Icons.email_outlined,
              controller: emailController,
              readOnly: true,
            ),
            isDark,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFieldWrapper(BuildContext context, Widget child, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha((0.2 * 255).round())
                : Colors.grey.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}