import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/utils/app_textstyles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'privacy_policy'.tr,
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'privacy_intro_title'.tr,
              'privacy_intro_content'.tr,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'privacy_data_collection_title'.tr,
              'privacy_data_collection_content'.tr,
            ),
            const SizedBox(height: 16),
            _buildBulletPoints(
              context,
              [
                'privacy_data_personal'.tr,
                'privacy_data_payment'.tr,
                'privacy_data_usage'.tr,
                'privacy_data_device'.tr,
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'privacy_data_usage_title'.tr,
              'privacy_data_usage_content'.tr,
            ),
            const SizedBox(height: 16),
            _buildBulletPoints(
              context,
              [
                'privacy_usage_orders'.tr,
                'privacy_usage_communication'.tr,
                'privacy_usage_improve'.tr,
                'privacy_usage_security'.tr,
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'privacy_data_sharing_title'.tr,
              'privacy_data_sharing_content'.tr,
            ),
            const SizedBox(height: 16),
            _buildBulletPoints(
              context,
              [
                'privacy_sharing_providers'.tr,
                'privacy_sharing_payment'.tr,
                'privacy_sharing_legal'.tr,
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'privacy_data_security_title'.tr,
              'privacy_data_security_content'.tr,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'privacy_your_rights_title'.tr,
              'privacy_your_rights_content'.tr,
            ),
            const SizedBox(height: 16),
            _buildBulletPoints(
              context,
              [
                'privacy_rights_access'.tr,
                'privacy_rights_correction'.tr,
                'privacy_rights_deletion'.tr,
                'privacy_rights_opt_out'.tr,
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'privacy_cookies_title'.tr,
              'privacy_cookies_content'.tr,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'privacy_children_title'.tr,
              'privacy_children_content'.tr,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'privacy_changes_title'.tr,
              'privacy_changes_content'.tr,
            ),
            const SizedBox(height: 24),
            _buildContactSection(context),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'privacy_last_updated'.tr,
                style: AppTextStyles.withColor(
                  AppTextStyles.bodySmall,
                  isDark ? Colors.grey[500]! : Colors.grey[600]!,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: AppTextStyles.withColor(
            AppTextStyles.bodyMedium,
            isDark ? Colors.grey[300]! : Colors.grey[800]!,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoints(BuildContext context, List<String> points) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points.map((point) {
        return Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: AppTextStyles.withColor(
                  AppTextStyles.bodyMedium,
                  Theme.of(context).primaryColor,
                ),
              ),
              Expanded(
                child: Text(
                  point,
                  style: AppTextStyles.withColor(
                    AppTextStyles.bodyMedium,
                    isDark ? Colors.grey[300]! : Colors.grey[800]!,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withAlpha((0.3 * 255).round()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_support,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'privacy_contact_title'.tr,
                style: AppTextStyles.withColor(
                  AppTextStyles.h3,
                  isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'privacy_contact_content'.tr,
            style: AppTextStyles.withColor(
              AppTextStyles.bodyMedium,
              isDark ? Colors.grey[300]! : Colors.grey[800]!,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.email,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'support@storeapp.com',
                style: AppTextStyles.withColor(
                  AppTextStyles.bodyMedium,
                  Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
