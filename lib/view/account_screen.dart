import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/controllers/auth_controller.dart';
import 'package:store_app/features/profile/edit_profile/views/screens/edit_profile_screen.dart';
import 'package:store_app/features/orders/view/screen/my_order_screen.dart';
import 'package:store_app/shipping_address/shipping_address_screen.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:store_app/view/settings_screen.dart';
import 'package:store_app/view/signin_screen.dart';
import 'package:store_app/view/help_center_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'my_account'.tr,
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => SettingsScreen()),
            icon: const Icon(Icons.settings_outlined),
            color: isDark ? Colors.white : Colors.black,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(context),
            const SizedBox(height: 24),
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/avatar.jpg'),
          ),
          const SizedBox(height: 16),
          Text(
            'Quái vật hồ Lockness',
            style: AppTextStyles.withColor(
              AppTextStyles.h2,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'trankimthanh230@gmail.com',
            style: AppTextStyles.withColor(
              AppTextStyles.bodyMedium,
              isDark ? Colors.grey[400]! : Colors.grey[600]!,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Get.to(() => EditProfileScreen()),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              side: BorderSide(
                color: isDark ? Colors.white70 : Colors.black12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'edit_profile'.tr,
              style: AppTextStyles.withColor(
                AppTextStyles.buttonMedium,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final menuItems = [
      {'icon': Icons.shopping_bag_outlined, 'key': 'my_orders'},
      {'icon': Icons.location_on_outlined, 'key': 'shipping_address'},
      {'icon': Icons.help_outline, 'key': 'help_center'},
      {'icon': Icons.logout_outlined, 'key': 'logout'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: menuItems.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
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
                item['icon'] as IconData,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                (item['key'] as String).tr,
                style: AppTextStyles.withColor(
                  AppTextStyles.bodyMedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              onTap: () {
                final key = item['key'] as String;
                if (key == 'logout') {
                  _showLogoutDialog(context);
                } else if (key == 'my_orders') {
                  Get.to(() => MyOrderScreen());
                } else if (key == 'shipping_address') {
                  Get.to(() => ShippingAddressScreen());
                } else if (key == 'help_center') {
                  Get.to(() => const HelpCenterScreen());
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .primaryColor
                    .withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'are_you_sure_logout'.tr,
              style: AppTextStyles.withColor(
                AppTextStyles.bodyMedium,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                    ),
                    child: Text(
                      'cancel'.tr,
                      style: AppTextStyles.withColor(
                      AppTextStyles.buttonMedium,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                    final AuthController authController = Get.find<AuthController>();
                    authController.logout();
                    Get.offAll(() => SigninScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                    ),
                    child: Text(
                      'logout'.tr,
                      style: AppTextStyles.withColor(
                      AppTextStyles.buttonMedium,
                      Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}