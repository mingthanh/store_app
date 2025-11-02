import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/controllers/wishlist_controller.dart';
import 'package:store_app/models/product.dart';
import 'package:store_app/controllers/cart_controller.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:store_app/utils/shopping_utils.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'my_wishlist'.tr,
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: GetBuilder<WishlistController>(
        builder: (controller) {
          final wishlist = controller.wishlist;
          return CustomScrollView(
            slivers: [
              // 📌 Summary section
              SliverToBoxAdapter(
                child: _buildSummarySection(context, wishlist.length),
              ),

              // 📦 Wishlist items
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildWishlistItem(context, wishlist[index]),
                    childCount: wishlist.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 🔹 Summary section - top part showing item count
  Widget _buildSummarySection(BuildContext context, int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🧱 Left text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'items_count'.trParams({'count': '$count'}),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.withColor(
                    AppTextStyles.h2,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'wishlist_in_your'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.withColor(
                    AppTextStyles.bodyMedium,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 🧡 Add all to cart button (width constrained to avoid overflow)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: ElevatedButton(
              onPressed: () {
                if (!ShoppingUtils.checkShoppingPermission()) {
                  return;
                }
                final cart = Get.put(CartController(), permanent: true);
                final controller = Get.find<WishlistController>();
                for (final p in controller.wishlist) {
                  cart.add(p, qty: 1);
                }
                controller.clearWishlist();
                Get.snackbar('Added', 'All wishlist items moved to cart', snackPosition: SnackPosition.BOTTOM);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                minimumSize: const Size(0, 40),
              ),
              child: Text(
                'add_all_to_cart'.tr,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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

  /// 🔹 Single Wishlist Item Card
  Widget _buildWishlistItem(BuildContext context, Product product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            child: (product.imageUrl.startsWith('http://') || product.imageUrl.startsWith('https://'))
                ? Image.network(
                    product.imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    product.imageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.withColor(
                      AppTextStyles.bodyLarge,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: AppTextStyles.withColor(
                      AppTextStyles.bodySmall,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: AppTextStyles.withColor(
                          AppTextStyles.h3,
                          Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (!ShoppingUtils.checkShoppingPermission()) {
                                return;
                              }
                              final cart = Get.put(CartController(), permanent: true);
                              cart.add(product, qty: 1);
                              // remove from wishlist after adding
                              Get.find<WishlistController>().toggleFavorite(product);
                              Get.snackbar('Added to cart', product.name, snackPosition: SnackPosition.BOTTOM);
                            },
                            icon: const Icon(Icons.shopping_cart_outlined),
                            color: Theme.of(context).primaryColor,
                          ),
                          IconButton(
                            onPressed: () => Get.find<WishlistController>()
                                .toggleFavorite(product),
                            icon: const Icon(Icons.delete_outline),
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}