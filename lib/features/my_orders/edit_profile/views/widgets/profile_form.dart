import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/widgets/custom_textfield.dart';

class ProfileForm extends StatelessWidget {
  const ProfileForm({super.key});

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
              initialValue: 'Quái vật hồ LochNess',
            ),
            isDark,
          ),
          const SizedBox(height: 16),
          _buildFieldWrapper(
            context,
            CustomTextfield(
              label: 'phone_number'.tr,
              prefixIcon: Icons.phone_outlined,
              initialValue: '0393759985',
            ),
            isDark,
          ),
          const SizedBox(height: 16),
          _buildFieldWrapper(
            context,
            CustomTextfield(
              label: 'email'.tr,
              prefixIcon: Icons.email_outlined,
              initialValue: 'trankimthanh230@gmail.com',
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