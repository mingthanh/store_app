import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/controllers/api_auth_controller.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:file_picker/file_picker.dart';
import 'package:store_app/repositories/upload_repository.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final auth = Get.find<ApiAuthController>();
  final avatar = auth.avatarUrl.value.trim(); // URL ảnh đại diện hiện tại (có thể rỗng)
    ImageProvider imageProvider;
    if (avatar.isNotEmpty && (avatar.startsWith('http://') || avatar.startsWith('https://'))) {
      imageProvider = NetworkImage(avatar);
    } else {
      imageProvider = const AssetImage('assets/images/avatar.jpg');
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              )
            ),
          ),
          // Nút máy ảnh nhỏ overlay để mở bottom sheet chọn nguồn ảnh
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showImagePickerBottomSheet(context, isDark),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withAlpha((0.3 * 255).round())
                          : Colors.grey.withAlpha((0.3 * 255).round()),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  // Hiện bottom sheet cho các lựa chọn đổi avatar: chụp ảnh (để sau), chọn từ gallery, dán URL
  void _showImagePickerBottomSheet(BuildContext context, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text('change_profile_picture'.tr,
                style: AppTextStyles.withColor(
                  AppTextStyles.h3,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                )
                ),
            const SizedBox(height: 24),
            _buildOptionTile(
              context,
              'take_photo'.tr,
              Icons.camera_alt_outlined,
              () => Get.back(),
              isDark,
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              context,
              'choose_from_gallery'.tr,
              Icons.photo_library_outlined,
              () async {
                Get.back();
                try {
                  final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                  if (res != null && res.files.isNotEmpty) {
                    final file = res.files.single;
                    final bytes = file.bytes;
                    if (bytes != null) {
                      final auth = Get.find<ApiAuthController>();
                      final token = auth.token.value;
                      if (token == null || token.isEmpty) {
                        Get.snackbar('Error', 'Please sign in again', snackPosition: SnackPosition.BOTTOM);
                        return;
                      }
                      final url = await UploadRepository.instance.uploadImageBytes(token, bytes, file.name);
                      final ok = await auth.updateProfile(newAvatarUrl: url);
                      if (ok) Get.snackbar('Profile', 'Avatar updated', snackPosition: SnackPosition.BOTTOM);
                    }
                  }
                } catch (e) {
                  Get.snackbar('Upload failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
                }
              },
              isDark,
            ),
            const SizedBox(height: 16),
            // Cho phép dán URL ảnh trực tiếp và cập nhật ngay
            _buildOptionTile(
              context,
              'Paste image URL',
              Icons.link_outlined,
              () async {
                Get.back();
                final ctrl = TextEditingController();
                final urlOk = await Get.dialog<bool>(AlertDialog(
                  title: const Text('Set avatar by URL'),
                  content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Image URL (http/https)')),
                  actions: [
                    TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Set')),
                  ],
                ));
                if (urlOk == true && ctrl.text.trim().isNotEmpty) {
                  final auth = Get.find<ApiAuthController>();
                  final ok = await auth.updateProfile(newAvatarUrl: ctrl.text.trim());
                  if (ok) Get.snackbar('Profile', 'Avatar updated', snackPosition: SnackPosition.BOTTOM);
                }
              },
              isDark,
            ),

          ],
        ),
      ),
    );
  }
  Widget _buildOptionTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTextStyles.withColor(
                AppTextStyles.bodyMedium,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}