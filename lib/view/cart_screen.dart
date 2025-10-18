import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/models/product.dart';
import 'package:store_app/utils/app_textstyles.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'My cart',
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) => _buildCartItem(
                context,
                products[index],
              ),
            ),
          ),
          _buildCartSummary(context),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, Product product) {
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
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(16)),
            child: Image.asset(
              product.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        product.name,
                        style: AppTextStyles.withColor(
                          AppTextStyles.bodyLarge,
                          Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                      IconButton(
                        onPressed: () =>
                            _showDeleteConfirmationDialog(context, product),
                        icon: const Icon(Icons.delete_outlined),
                        color: Colors.red[400],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price}',
                        style: AppTextStyles.withColor(
                          AppTextStyles.h3,
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.remove,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                )),
                            Text(
                              '1',
                              style: AppTextStyles.withColor(
                                AppTextStyles.bodyLarge,
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[400]!.withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red[400],
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Remove Item',
              style: AppTextStyles.withColor(
                AppTextStyles.h3,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to remove this item from your cart?',
              textAlign: TextAlign.center,
              style: AppTextStyles.withColor(
                AppTextStyles.bodyMedium,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.black12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            )),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.withColor(
                            AppTextStyles.bodyMedium,
                            Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color!,
                          ),
                        ))),
                const SizedBox(width: 16),
                Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          // TODO: Xử lý xóa item ở đây
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Remove',
                          style: AppTextStyles.withColor(
                            AppTextStyles.bodyMedium,
                            Colors.white,
                          ),
                        ))),
              ],
            )
          ],
        ),
      ),
      barrierColor: Colors.black54,
    );
  }

  Widget _buildCartSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total (4 items)',
                style: AppTextStyles.withColor(
                  AppTextStyles.bodyMedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              Text(
                '\$999.99',
                style: AppTextStyles.withColor(
                  AppTextStyles.h2,
                  Theme.of(context).primaryColor,
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: navigate to checkout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Proceed to Checkout',
                style: AppTextStyles.withColor(
                  AppTextStyles.buttonMedium,
                  Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}