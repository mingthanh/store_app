import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/view/qr_scanner_screen.dart';
import 'package:store_app/view/order_tracking_screen.dart';
import 'package:store_app/view/order_qr_display_screen.dart';
import 'package:store_app/utils/app_textstyles.dart';

/// Development screen to quickly test tracking features
class TrackingTestScreen extends StatefulWidget {
  const TrackingTestScreen({super.key});

  @override
  State<TrackingTestScreen> createState() => _TrackingTestScreenState();
}

class _TrackingTestScreenState extends State<TrackingTestScreen> {
  final _trackingIdController = TextEditingController();

  @override
  void dispose() {
    _trackingIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tracking Test',
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Quick Testing Tools',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use these tools to quickly test tracking features without going through the full order flow.',
                      style: TextStyle(
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // QR Scanner Test
            _buildTestCard(
              context,
              title: '1. QR Scanner (Staff)',
              description: 'Test QR scanning functionality',
              icon: Icons.qr_code_scanner,
              color: Colors.blue,
              onTap: () => Get.to(() => const QrScannerScreen()),
            ),

            const SizedBox(height: 12),

            // Generate QR Test
            _buildTestCard(
              context,
              title: '2. Generate QR Code',
              description: 'Generate a test QR code',
              icon: Icons.qr_code,
              color: Colors.green,
              onTap: () {
                Get.to(() => const OrderQrDisplayScreen(
                  trackingId: 'TRK1730600001TEST',
                  orderNumber: 'TEST-001',
                ));
              },
            ),

            const SizedBox(height: 12),

            // View Tracking Test
            _buildTestCard(
              context,
              title: '3. View Tracking',
              description: 'View tracking with real tracking ID',
              icon: Icons.location_on,
              color: Colors.orange,
              onTap: () => _showTrackingIdDialog(context),
            ),

            const SizedBox(height: 12),

            // Demo Tracking Test
            _buildTestCard(
              context,
              title: '4. Demo Tracking (Mock Data)',
              description: 'View tracking screen with sample data',
              icon: Icons.map,
              color: Colors.purple,
              onTap: () {
                Get.snackbar(
                  'Info',
                  'This will show tracking screen with the entered tracking ID',
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
              },
            ),

            const SizedBox(height: 32),

            // Quick Links
            Text(
              'Quick Links',
              style: AppTextStyles.withColor(
                AppTextStyles.h3,
                isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            _buildQuickLink(
              context,
              'Backend API Docs',
              Icons.api,
              () {
                Get.snackbar(
                  'API Endpoints',
                  'POST /api/tracking/scan\nGET /api/tracking/:trackingId',
                );
              },
            ),

            const SizedBox(height: 8),

            _buildQuickLink(
              context,
              'Setup Guide',
              Icons.book,
              () {
                Get.snackbar(
                  'Documentation',
                  'See TRACKING_SETUP.md for full setup guide',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLink(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.withAlpha((0.3 * 255).round())),
      ),
    );
  }

  void _showTrackingIdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Tracking ID'),
        content: TextField(
          controller: _trackingIdController,
          decoration: const InputDecoration(
            labelText: 'Tracking ID',
            hintText: 'TRK...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final trackingId = _trackingIdController.text.trim();
              if (trackingId.isEmpty) {
                Get.snackbar('Error', 'Please enter tracking ID');
                return;
              }
              Navigator.of(ctx).pop();
              Get.to(() => OrderTrackingScreen(trackingId: trackingId));
            },
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}
