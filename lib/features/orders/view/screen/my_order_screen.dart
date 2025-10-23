import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/features/orders/model/order.dart';
import 'package:store_app/features/orders/repository/order_repository.dart';
import 'package:store_app/features/orders/view/widget/order_card.dart';
import 'package:store_app/utils/app_textstyles.dart';

class MyOrderScreen extends StatelessWidget {
  final OrderRepository _repository = OrderRepository();
  MyOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(length: 3, child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(), 
          icon: Icon(Icons.arrow_back_ios,
          color: isDark ? Colors.white : Colors.black,
          ),
          ),
        title: Text(
          'my_orders'.tr,
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        bottom: TabBar(
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(text: 'active_tab'.tr),
            Tab(text: 'completed_tab'.tr),
            Tab(text: 'cancelled_tab'.tr),
          ]
          ),
      ),
      body: TabBarView(
        children: [
          _buildOrderList(context, OrderStatus.active),
          _buildOrderList(context, OrderStatus.completed),
          _buildOrderList(context, OrderStatus.cancelled),
          ],
        ),
      ),
    );
  }
  Widget _buildOrderList(BuildContext context, OrderStatus status){
    final order = _repository.getActiveOrders(status);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: order.length,
      itemBuilder: (context, index) => Ordercard(
        order: order[index],
        onViewDetails: (){
          // Navigate to order details screen
        },
      ),
    );
  }
}
