import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:url_launcher/url_launcher.dart';

/// Màn hình Trung tâm trợ giúp (Help Center)
/// - Đơn giản hiển thị tiêu đề và nội dung placeholder
/// - Có thể mở rộng thêm FAQ, liên hệ hỗ trợ, v.v. trong tương lai
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final phone = '0393759985';
    final email = 'trankimthanh230@gmail.com';

    final faqs = [
      {'q': 'faq_orders_q'.tr, 'a': 'faq_orders_a'.tr},
      {'q': 'faq_return_q'.tr, 'a': 'faq_return_a'.tr},
      {'q': 'faq_payment_q'.tr, 'a': 'faq_payment_a'.tr},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'help_center'.tr,
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Intro
            Text(
              'help_center_intro'.tr,
              style: AppTextStyles.withColor(
                AppTextStyles.bodyLarge,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            const SizedBox(height: 16),
            // FAQs section
            Text(
              'faqs'.tr,
              style: AppTextStyles.withColor(
                AppTextStyles.h3,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            const SizedBox(height: 8),
            ...faqs.map((f) => Card(
                  elevation: 0,
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      f['q'] as String,
                      style: AppTextStyles.withColor(
                        AppTextStyles.bodyMedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          f['a'] as String,
                          style: AppTextStyles.withColor(
                            AppTextStyles.bodySmall,
                            Theme.of(context).textTheme.bodyLarge!.color!,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            // Contact section
            Text(
              'contact_support'.tr,
              style: AppTextStyles.withColor(
                AppTextStyles.h3,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: Text(
                  'call_us'.tr,
                  style: AppTextStyles.withColor(
                    AppTextStyles.bodyMedium,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                subtitle: Text(phone),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final uri = Uri(scheme: 'tel', path: phone);
                  await launchUrl(uri);
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(
                  'email_us'.tr,
                  style: AppTextStyles.withColor(
                    AppTextStyles.bodyMedium,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                subtitle: Text(email),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final uri = Uri(
                    scheme: 'mailto',
                    path: email,
                    query: Uri(queryParameters: {
                      'subject': 'Support Request',
                    }).query,
                  );
                  await launchUrl(uri);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
