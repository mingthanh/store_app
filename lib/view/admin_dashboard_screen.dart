import 'package:flutter/material.dart';
import 'package:store_app/services/firestore_service.dart';
import 'package:store_app/utils/app_textstyles.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String? _filterStatus; // null = all

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          FutureBuilder<Map<String, num>>(
            future: FirestoreService.instance.ordersSummary(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: LinearProgressIndicator(),
                );
              }
              final s = snap.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metric(context, 'Orders', s['count']?.toInt() ?? 0),
                    _metric(context, 'Revenue', (s['revenue']?.toInt() ?? 0).toString()),
                    _metric(context, 'Processing', s['status_processing']?.toInt() ?? 0),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                DropdownButton<String?>(
                  value: _filterStatus,
                  hint: const Text('Filter status'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: 'processing', child: Text('Processing')),
                    DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                    DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (v) => setState(() => _filterStatus = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService.instance.ordersStream(status: _filterStatus),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snap.data!;
                if (orders.isEmpty) {
                  return const Center(child: Text('No orders'));
                }
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, i) => _orderTile(context, orders[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String title, Object value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withAlpha(30),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: AppTextStyles.bodySmall.copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 4),
          Text('$value', style: AppTextStyles.h3),
        ],
      ),
    );
  }

  Widget _orderTile(BuildContext context, Map<String, dynamic> o) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = o['id'] as String;
    final status = (o['status'] as String?) ?? 'processing';
    final total = (o['totalAmount'] as num?)?.toInt() ?? 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withAlpha(30),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #$id', style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text('Total: $total', style: AppTextStyles.bodySmall.copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600])),
              ],
            ),
          ),
          DropdownButton<String>(
            value: status,
            items: const [
              DropdownMenuItem(value: 'processing', child: Text('Processing')),
              DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
              DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (v) async {
              if (v == null) return;
              await FirestoreService.instance.updateOrderStatus(orderId: id, status: v);
            },
          ),
        ],
      ),
    );
  }
}
