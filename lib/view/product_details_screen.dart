import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:store_app/models/product.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:store_app/utils/shopping_utils.dart';
import 'package:store_app/controllers/cart_controller.dart';
import 'package:store_app/view/cart_screen.dart';
import 'package:store_app/widgets/size_selector.dart';

/// Màn hình chi tiết sản phẩm
///
/// - Hiển thị ảnh, tên, giá, danh mục, mô tả
/// - Hành động: chia sẻ, thêm vào giỏ, mua ngay
/// - Hỗ trợ định dạng giá theo USD/VND dựa trên nguồn dữ liệu
class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: isDark ? Colors.white : Colors.black,
        ),
        title: Text(
          'details_title'.tr,
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _shareProduct(
              context,
              product.name,
              product.description,
            ),
            icon: const Icon(Icons.share),
            color: isDark ? Colors.white : Colors.black,
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Product image
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildProductImage(product.imageUrl),
                ),

                // Favorite button
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: product.isFavorite
                          ? Theme.of(context).primaryColor
                          : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                ),
              ],
            ),

            // Product details
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name + price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTextStyles.withColor(
                            AppTextStyles.h2,
                            Theme.of(context).textTheme.headlineMedium!.color!,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatPrice(product.price, product.imageUrl),
                        style: AppTextStyles.withColor(
                          AppTextStyles.h2,
                          Theme.of(context).textTheme.headlineMedium!.color!,
                        ),
                      ),
                    ],
                  ),

                  // Category
                  Text(
                    product.category,
                    style: AppTextStyles.withColor(
                      AppTextStyles.bodyMedium,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Select size
                  Text(
                    'select_size'.tr,
                    style: AppTextStyles.withColor(
                      AppTextStyles.labelMedium,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  const SizeSelector(),

                  SizedBox(height: screenHeight * 0.02),

                  // Description
                  Text(
                    'description'.tr,
                    style: AppTextStyles.withColor(
                      AppTextStyles.labelMedium,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    product.description,
                    style: AppTextStyles.withColor(
                      AppTextStyles.bodyMedium,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom buttons
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Row(
            children: [
              // Add to Cart
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (!ShoppingUtils.checkShoppingPermission()) {
                      return;
                    }
                    final cart = Get.put(CartController(), permanent: true);
                    cart.add(product, qty: 1);
                    Get.snackbar('Added to cart', product.name, snackPosition: SnackPosition.BOTTOM);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                    ),
                    side: BorderSide(
                      color: isDark ? Colors.white70 : Colors.black12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                  label: Text(
                    'add_to_cart'.tr,
                    style: AppTextStyles.withColor(
                      AppTextStyles.labelMedium,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 💳 Buy Now
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (!ShoppingUtils.checkShoppingPermission()) {
                      return;
                    }
                    final cart = Get.put(CartController(), permanent: true);
                    cart.add(product, qty: 1);
                    Get.to(() => const CartScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.credit_card, color: Colors.white),
                  label: Text(
                    'buy_now'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Share product
  /// Chia sẻ thông tin sản phẩm ra bên ngoài (Share)
  Future<void> _shareProduct(
    BuildContext context,
    String productName,
    String description,
  ) async {
    final box = context.findRenderObject() as RenderBox?;
  const String shopLink =
    'https://www.nike.com/vn/w/jordan-shoes-37eefzy7ok';
  final String shareMessage =
    '$description\n${'share_shop_now'.trParams({'link': shopLink})}';
    try {
      // ignore: deprecated_member_use, unused_local_variable
      final ShareResult result = await Share.share(
        shareMessage,
        subject: productName,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
      debugPrint('Thanks for sharing!');
    } catch (e) {
      debugPrint('Error sharing: $e');
    }
  }

  /// Xây dựng widget ảnh sản phẩm, tự nhận biết ảnh mạng/ảnh local
  Widget _buildProductImage(String url) {
    final isNetwork = url.startsWith('http');
    if (isNetwork) {
      return Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image),
        ),
      );
    }
    return Image.asset(
      url,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  /// Định dạng giá hiển thị
  ///
  /// - Nếu ảnh là URL mạng (thường là dữ liệu Firestore) -> coi là VND và thêm dấu chấm ngăn cách + hậu tố "đ"
  /// - Ngược lại -> hiển thị USD với dấu $ và 2 chữ số thập phân
  String _formatPrice(double price, String imageUrl) {
    // Heuristic: Firestore products use VND and network images
    final isVnd = imageUrl.startsWith('http');
    if (!isVnd) {
      return '\$${price.toStringAsFixed(2)}';
    }
    final p = price.round();
    final s = p.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buffer.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buffer.write('.');
    }
    return '${buffer.toString()} đ';
  }
}