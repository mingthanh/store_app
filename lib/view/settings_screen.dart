import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/controllers/theme_controller.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:get_storage/get_storage.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          'settings'.tr,
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'appearance'.tr,
              [
                _buildThemeToggle(context),
              ],
            ),
            _buildSection(
              context,
              'notifications'.tr,
              [
                _buildSwitchTile(
                  context,
                  'push_notifications'.tr,
                  'receive_push_sub'.tr,
                  true,
                ),
              ],
            ),
            _buildSection(
              context,
              'notifications'.tr,
              [
                _buildSwitchTile(
                  context,
                  'email_notifications'.tr,
                  'receive_email_sub'.tr,
                  false,
                ),
              ],
            ),
            _buildSection(
              context,
              'privacy'.tr,
              [
                _buildNavigationTile(
                  context,
                  'privacy_policy'.tr,
                  'view_privacy'.tr,
                  Icons.privacy_tip_outlined,
                ),
                _buildNavigationTile(
                  context,
                  'terms_of_service'.tr,
                  'read_terms'.tr,
                  Icons.description_outlined,
                ),
              ],
            ),
            _buildSection(
              context,
              'about'.tr,
              [
                _buildNavigationTile(
                  context,
                  'app_version'.tr,
                  '1.0.0',
                  Icons.info_outline,
                ),
                const SizedBox(height: 12),
                // Language selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'language'.tr,
                        style: AppTextStyles.withColor(
                          AppTextStyles.bodyMedium,
                          Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                      ),
                      DropdownButton<String>(
                        value: Get.locale?.toString() ?? 'en_US',
                          items: [
                          DropdownMenuItem(value: 'en_US', child: Text('english'.tr)),
                          DropdownMenuItem(value: 'vi_VN', child: Text('vietnamese'.tr)),
                        ],
                        onChanged: (val) {
                          if (val == null) return;
                          final parts = val.split('_');
                          final locale = Locale(parts[0], parts[1]);
                          Get.updateLocale(locale);
                          final box = GetStorage();
                          box.write('locale', val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            title,
            style: AppTextStyles.withColor(
              AppTextStyles.h3,
              isDark ? Colors.grey[400]! : Colors.grey[600]!,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GetBuilder<ThemeController>(
            builder: (controller) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: ListTile(
          leading: Icon(
            controller.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(
            'Dark Mode',
            style: AppTextStyles.withColor(
              AppTextStyles.bodyMedium,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          trailing: Switch.adaptive(
            value: controller.isDarkMode,
            onChanged: (value) => controller.toggleTheme(),
            activeThumbColor: Theme.of(context).primaryColor,
            activeTrackColor: Theme.of(context).primaryColor.withAlpha((0.2 * 255).round()),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool initialValue,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: ListTile(
        title: Text(
          title,
          style: AppTextStyles.withColor(
            AppTextStyles.bodyMedium,
            Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.withColor(
            AppTextStyles.bodySmall,
            isDark ? Colors.grey[400]! : Colors.grey[600]!,
          ),
        ),
        trailing: Switch.adaptive(
          value: initialValue,
          onChanged: (value) {},
          activeThumbColor: Theme.of(context).primaryColor,
          activeTrackColor: Theme.of(context).primaryColor.withAlpha((0.2 * 255).round()),
        ),
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: AppTextStyles.withColor(
            AppTextStyles.bodyMedium,
            Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.withColor(
            AppTextStyles.bodySmall,
            isDark ? Colors.grey[400]! : Colors.grey[600]!,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        onTap: () {},
      ),
    );
  }
}