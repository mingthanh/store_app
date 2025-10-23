import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/utils/app_textstyles.dart';

/// Màn hình Điều khoản dịch vụ (Terms of Service)
/// - Nội dung cơ bản, có thể mở rộng/đồng bộ từ máy chủ trong tương lai
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sections = [
      {'t': 'tos_section1_title'.tr, 'b': 'tos_section1_body'.tr},
      {'t': 'tos_section2_title'.tr, 'b': 'tos_section2_body'.tr},
      {'t': 'tos_section3_title'.tr, 'b': 'tos_section3_body'.tr},
      {'t': 'tos_section4_title'.tr, 'b': 'tos_section4_body'.tr},
      {'t': 'tos_section5_title'.tr, 'b': 'tos_section5_body'.tr},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
          color: isDark ? Colors.white : Colors.black,
        ),
        title: Text(
          'terms_of_service'.tr,
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            'tos_intro'.tr,
            style: AppTextStyles.withColor(
              AppTextStyles.bodyMedium,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          const SizedBox(height: 16),
          ...sections.map((s) => _buildSection(context, s['t'] as String, s['b'] as String)).toList(),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String body) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha((0.1 * 255).round())
                : Colors.grey.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.withColor(
              AppTextStyles.h3,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppTextStyles.withColor(
              AppTextStyles.bodySmall,
              isDark ? Colors.grey[400]! : Colors.grey[700]!,
            ),
          ),
        ],
      ),
    );
  }
}
