import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/controllers/api_auth_controller.dart';
import 'package:store_app/repositories/order_api_repository.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:store_app/view/order_tracking_screen.dart';
import 'package:store_app/view/order_qr_display_screen.dart';
import 'package:store_app/widgets/tracking_status_badge.dart';

class MyOrdersApiScreen extends StatefulWidget {
  const MyOrdersApiScreen({super.key});

  @override
  State<MyOrdersApiScreen> createState() => _MyOrdersApiScreenState();
}

class _MyOrdersApiScreenState extends State<MyOrdersApiScreen> {
  final _auth = Get.find<ApiAuthController>();
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final t = _auth.token.value;
      
      // Check if user is logged in via social auth but has no API token
      if ((t == null || t.isEmpty) && _auth.isSocialLogin.value) {
        if (!mounted) return;
        setState(() => _loading = false);
        // Don't show error for social login users, just empty state
        return;
      }
      
      if (t == null || t.isEmpty) {
        Get.snackbar('Error', 'Please sign in again');
        Get.back();
        return;
      }
      
      final list = await OrderApiRepository.instance.myOrders(t);
      if (!mounted) return;
      setState(() {
        _orders = list.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
        ),
        title: Text('my_orders'.tr, style: AppTextStyles.withColor(AppTextStyles.h3, isDark ? Colors.white : Colors.black)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, i) => _buildOrderTile(context, _orders[i]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSocial = _auth.isSocialLogin.value;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSocial ? Icons.info_outline : Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isSocial 
                ? 'Orders not available for social login'
                : 'No orders yet',
              style: AppTextStyles.withColor(
                AppTextStyles.h3, 
                isDark ? Colors.white70 : Colors.black54
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSocial
                ? 'Orders feature is only available for email/password accounts. Please create an account with email and password to view your orders.'
                : 'Start shopping to see your orders here!',
              style: AppTextStyles.withColor(
                AppTextStyles.bodyMedium, 
                Colors.grey[600]!
              ),
              textAlign: TextAlign.center,
            ),
            if (isSocial) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  // Navigate to email signup screen if needed
                },
                icon: const Icon(Icons.email),
                label: const Text('Create Email Account'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile(BuildContext context, Map<String, dynamic> o) {
    final status = (o['status'] ?? 'pending').toString();
    final total = (o['totalAmount'] is num) ? (o['totalAmount'] as num).toDouble() : double.tryParse('${o['totalAmount']}') ?? 0.0;
    final items = (o['items'] as List?) ?? const [];
    final trackingId = o['trackingId'] as String?;
    final orderId = o['_id'] as String?;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            title: Text('Order ${orderId ?? ''}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${items.length} items • ${_formatVnd(total)}'),
                if (trackingId != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.qr_code_2, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          trackingId,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: _statusChip(context, status),
          ),
          // Action buttons
          if (trackingId != null && orderId != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.to(() => OrderTrackingScreen(
                          trackingId: trackingId,
                          orderId: orderId,
                        ));
                      },
                      icon: const Icon(Icons.location_on, size: 18),
                      label: const Text('Theo dõi'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.to(() => OrderQrDisplayScreen(
                          trackingId: trackingId,
                          orderNumber: orderId,
                        ));
                      },
                      icon: const Icon(Icons.qr_code, size: 18),
                      label: const Text('Xem QR'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context, String status) {
    return TrackingStatusBadge(status: status);
  }

  String _formatVnd(double price) {
    final p = price.round();
    final s = p.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      b.write(s[i]);
      if (idx > 1 && idx % 3 == 1) b.write('.');
    }
    return '${b.toString()} đ';
  }
}
