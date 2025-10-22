import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/features/orders/model/order.dart';
import 'package:store_app/utils/app_textstyles.dart';

class Ordercard extends StatelessWidget {
  final Order order;
  final VoidCallback onViewDetails;

  const Ordercard({super.key, required this.order, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(order.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'order_label'.tr} #${order.orderNumber}',
                    style: AppTextStyles.withColor(
                      AppTextStyles.h3, 
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'items_total'.trParams({
                      'items': order.itemCount.toString(),
                      'total': '\$${order.totalAmount.toStringAsFixed(2)}',
                    }),
                    style: AppTextStyles.withColor(
                      AppTextStyles.bodyMedium, 
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusChip(
                    context,
                    order.statusString,
                  )
                ],
              ),
              )
            ],
          ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          InkWell(
            onTap: onViewDetails,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'view_details'.tr,
                  style: AppTextStyles.withColor(
                    AppTextStyles.buttonMedium,
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatusChip(BuildContext context, String type){
    Color getStatusColor(){
      switch(type){
        case 'active':
          return Colors.green;
        case 'completed':
          return Colors.blue;
        case 'cancelled':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: getStatusColor().withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.capitalize!,
        style: AppTextStyles.withColor(
          AppTextStyles.bodyMedium,
          getStatusColor(),
        ),
      ),
    );
  }
}
