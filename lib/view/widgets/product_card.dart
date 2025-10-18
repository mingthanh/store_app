import 'package:flutter/material.dart';
import 'package:store_app/models/product.dart';
import 'package:store_app/utils/app_textstyles.dart';

// 🧮 Hàm tính phần trăm giảm giá
double calculateDiscount(double price, double oldPrice) {
  if (oldPrice <= price) return 0;
  final discount = ((oldPrice - price) / oldPrice) * 100;
  return discount;
}

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    // Lấy trạng thái yêu thích ban đầu từ product
    isFavorite = widget.product.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxWidth: screenWidth * 0.9,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
      color: isDark
        ? Colors.black.withAlpha((0.3 * 255).round())
        : Colors.grey.withAlpha((0.1 * 255).round()),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh sản phẩm + icon favorite + badge giảm giá
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.asset(
                    widget.product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // ❤️ Nút yêu thích
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.25 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                  ),
                ),
              ),

              // 🏷️ Badge giảm giá
              if (widget.product.oldPrice != null &&
                  widget.product.oldPrice! > widget.product.price)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha((0.9 * 255).round()),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '-${calculateDiscount(widget.product.price, widget.product.oldPrice!).toStringAsFixed(0)}% OFF',
                      style: AppTextStyles.withColor(
                        AppTextStyles.withWeight(
                          AppTextStyles.bodySmall,
                          FontWeight.bold,
                        ),
                        Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // 📄 Thông tin sản phẩm
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên sản phẩm
                Text(
                  widget.product.name,
                  style: AppTextStyles.withColor(
                    AppTextStyles.withWeight(
                      AppTextStyles.h3,
                      FontWeight.bold,
                    ),
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: screenWidth * 0.01),

                // Danh mục sản phẩm
                Text(
                  widget.product.category,
                  style: AppTextStyles.withColor(
                    AppTextStyles.bodyMedium,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),

                SizedBox(height: screenWidth * 0.01),

                // Giá
                Row(
                  children: [
                    Text(
                      '\$${widget.product.price.toStringAsFixed(2)}',
                      style: AppTextStyles.withColor(
                        AppTextStyles.withWeight(
                          AppTextStyles.bodyLarge,
                          FontWeight.bold,
                        ),
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                    if (widget.product.oldPrice != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '\$${widget.product.oldPrice!.toStringAsFixed(2)}',
                        style: AppTextStyles.withColor(
                          AppTextStyles.withWeight(
                            AppTextStyles.bodySmall,
                            FontWeight.w500,
                          ),
                          Colors.grey,
                        ).copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}