import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/controllers/api_auth_controller.dart';
import 'package:store_app/repositories/order_api_repository.dart';
import 'package:store_app/utils/app_textstyles.dart';

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
    return Card(
      child: ListTile(
        title: Text('Order ${o['_id'] ?? ''}'),
        subtitle: Text('${items.length} items • ${_formatVnd(total)}'),
        trailing: _statusChip(context, status),
      ),
    );
  }

  Widget _statusChip(BuildContext context, String status) {
    Color c;
    switch (status) {
      case 'processing':
        c = Colors.blue; break;
      case 'shipped':
        c = Colors.orange; break;
      case 'delivered':
        c = Colors.green; break;
      case 'cancelled':
        c = Colors.red; break;
      default:
        c = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      // ignore: deprecated_member_use
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: c)),
    );
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
