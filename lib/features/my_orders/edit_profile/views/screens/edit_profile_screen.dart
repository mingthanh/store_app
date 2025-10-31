import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/features/my_orders/edit_profile/views/widgets/profile_form.dart';
import 'package:store_app/features/my_orders/edit_profile/views/widgets/profile_image.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:store_app/controllers/api_auth_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  final _auth = Get.find<ApiAuthController>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _auth.name.value);
    _phoneCtrl = TextEditingController(text: _auth.phone.value);
    _emailCtrl = TextEditingController(text: _auth.email.value);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
          color: isDark ? Colors.white : Colors.black,
        ),
          title: Text(
            'edit_profile'.tr,
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const ProfileImage(),
            const SizedBox(height: 32),
            ProfileForm(
              nameController: _nameCtrl,
              phoneController: _phoneCtrl,
              emailController: _emailCtrl,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
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
                          borderRadius: BorderRadius.circular(12),
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
                      onPressed: _saving
                          ? null
                          : () async {
                              setState(() => _saving = true);
                              final ok = await _auth.updateProfile(
                                newName: _nameCtrl.text.trim(),
                                newPhone: _phoneCtrl.text.trim(),
                              );
                              setState(() => _saving = false);
                              if (ok) {
                                Get.back();
                                Get.snackbar(
                                  'edit_profile'.tr,
                                  'profile_updated'.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } else {
                                Get.snackbar(
                                  'edit_profile'.tr,
                                  _auth.lastError.value.isNotEmpty
                                      ? _auth.lastError.value
                                      : 'Update failed',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.redAccent,
                                  colorText: Colors.white,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _saving ? 'saving'.tr : 'save'.tr,
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}