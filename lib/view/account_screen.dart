import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_app/controllers/auth_controller.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'signin_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final box = GetStorage();
    final rawFb = box.read('fbUser');
    final Map? user = (rawFb is Map ? rawFb : null);

    final avatarUrl = user == null
        ? null
        : (user['picture']?['data']?['url'] as String?);
    final name = user == null ? 'Guest' : (user['name'] as String? ?? 'User');
    final email = user == null ? null : (user['email'] as String?);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Icon(Icons.person, size: 48, color: Colors.grey.shade600)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(name, style: AppTextStyles.h2),
            if (email != null) ...[
              const SizedBox(height: 8),
              Text(
                email,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  auth.logout();
                  Get.offAll(() => SigninScreen());
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: Text(
                  'Log out',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: Colors.redAccent,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
