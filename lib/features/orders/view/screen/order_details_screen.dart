import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/features/orders/model/order.dart';
import 'package:store_app/utils/app_textstyles.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
        ),
        title: Text(
          'Order #${order.orderNumber}',
          style: AppTextStyles.withColor(AppTextStyles.h3, isDark ? Colors.white : Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: AssetImage(order.imageUrl), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${order.itemCount} items', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 4),
                      Text('\$${order.totalAmount.toStringAsFixed(2)}',
                          style: AppTextStyles.withColor(AppTextStyles.h3, Theme.of(context).primaryColor)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text('Status: ${order.statusString.capitalizeFirst}', style: AppTextStyles.bodyLarge),
            const SizedBox(height: 8),
            Text('Placed: ${order.dateString}', style: AppTextStyles.bodyMedium),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                child: Text('Close', style: AppTextStyles.buttonMedium),
              ),
            )
          ],
        ),
      ),
    );
  }
}
