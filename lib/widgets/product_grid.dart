import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/services/firestore_service.dart';
import 'package:store_app/repositories/product_repository.dart';
import 'package:store_app/models/product.dart' as model;
import 'package:store_app/view/product_details_screen.dart';
import 'package:store_app/widgets/product_card.dart';
import 'package:shimmer/shimmer.dart';

class ProductGrid extends StatelessWidget {
  final String? category;
  final int limit;
  // Nếu true thì dùng danh sách local `products` trong `lib/models/product.dart`
  final bool useLocal;
  // Dùng API (MongoDB backend)
  final bool useApi;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ProductGrid({
    super.key,
    this.category,
    this.limit = 50,
    this.shrinkWrap = false,
    this.physics,
    this.useLocal = false,
    this.useApi = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useLocal) {
      final items = model.products;
      if (items.isEmpty) return const Center(child: Text('Chưa có sản phẩm'));
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        shrinkWrap: shrinkWrap,
        physics:
            physics ??
            (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final p = items[index];
          return GestureDetector(
            onTap: () {
              Get.to(() => ProductDetailsScreen(product: p));
            },
            child: ProductCard(product: p),
          );
        },
      );
    }

    // Nếu dùng API (Mongo backend)
    if (useApi) {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: ProductRepository.instance.fetchProducts(category: category, limit: limit),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const _ShimmerGrid();
          }
          if (snap.hasError) {
            return Center(child: Text('Lỗi tải sản phẩm: ${snap.error}'));
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return const Center(child: Text('Chưa có sản phẩm'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            shrinkWrap: shrinkWrap,
            physics: physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final p = items[index];
              final name = (p['name'] ?? '').toString();
              final rawPrice = p['price'];
              final price = (rawPrice is num) ? rawPrice.toInt() : int.tryParse(rawPrice?.toString() ?? '') ?? 0;
              final imageUrl = (p['imageUrl'] ?? '').toString();
              final mongoId = (p['_id'] ?? '').toString();
              final generatedId = mongoId.isNotEmpty ? mongoId.hashCode : (index + 1);

              final product = model.Product(
                id: generatedId,
                name: name,
                price: price.toDouble(),
                imageUrl: imageUrl.isEmpty ? 'assets/images/shoe.jpg' : imageUrl,
                category: (p['category'] ?? '').toString(),
                description: (p['description'] ?? '').toString(),
                isFavorite: false,
              );
              return GestureDetector(
                onTap: () => Get.to(() => ProductDetailsScreen(product: product)),
                child: ProductCard(product: product),
              );
            },
          );
        },
      );
    }

    // Nếu dùng Firestore
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.instance.productsStream(
        category: category,
        limit: limit,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _ShimmerGrid();
        }
        if (snap.hasError) {
          return Center(child: Text('Lỗi tải sản phẩm: ${snap.error}'));
        }
        final items = snap.data ?? const [];
        if (items.isEmpty) {
          return const Center(child: Text('Chưa có sản phẩm'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          shrinkWrap: shrinkWrap,
          physics:
              physics ??
              (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final p = items[index];
            final name = (p['name'] ?? '').toString();
            // Giá có thể được lưu dưới dạng số hoặc chuỗi trong Firestore -> handle both
            final rawPrice = p['price'];
            double price;
            if (rawPrice is num) {
              price = rawPrice.toDouble();
            } else if (rawPrice is String) {
              price = double.tryParse(rawPrice) ?? 0.0;
            } else {
              price = 0.0;
            }
            final imageUrl = (p['imageUrl'] ?? '').toString();
            final category = (p['category'] ?? '').toString();
            final description = (p['description'] ?? '').toString();

            // ID cũng có thể là string hoặc int
            final rawId = p['id'];
            int id;
            if (rawId is int) {
              id = rawId;
            } else if (rawId is String) {
              id = int.tryParse(rawId) ?? 0;
            } else {
              id = 0;
            }

            // ✅ Tạo object Product từ Firestore (có cả id)
            final product = model.Product(
              id: id,
              name: name,
              price: price,
              imageUrl: imageUrl.isEmpty ? 'assets/images/shoe.jpg' : imageUrl,
              category: category,
              description: description,
              isFavorite: false,
            );

            return GestureDetector(
              onTap: () => Get.to(() => ProductDetailsScreen(product: product)),
              child: ProductCard(product: product),
            );
          },
        );
      },
    );
  }
}

// _ProductCard removed in favor of ProductCard (which includes wishlist button)

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
