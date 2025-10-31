import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/services/firestore_service.dart';
import 'package:store_app/repositories/product_repository.dart';
import 'package:store_app/models/product.dart' as model;
import 'package:store_app/view/product_details_screen.dart';
import 'package:store_app/widgets/product_card.dart';

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
            return const Center(child: CircularProgressIndicator());
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

              return GestureDetector(
                onTap: () {
                  final product = model.Product(
                    id: generatedId,
                    name: name,
                    price: price.toDouble(),
                    imageUrl: imageUrl.isEmpty ? 'assets/images/shoe.jpg' : imageUrl,
                    category: (p['category'] ?? '').toString(),
                    description: (p['description'] ?? '').toString(),
                    isFavorite: false,
                  );
                  Get.to(() => ProductDetailsScreen(product: product));
                },
                child: _ProductCard(
                  name: name,
                  price: price,
                  imageUrl: imageUrl,
                ),
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
          return const Center(child: CircularProgressIndicator());
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
              onTap: () {
                Get.to(() => ProductDetailsScreen(product: product));
              },
              child: _ProductCard(
                name: name,
                price: price.toInt(),
                imageUrl: imageUrl,
              ),
            );
          },
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String name;
  final int price;
  final String? imageUrl;

  const _ProductCard({required this.name, required this.price, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Use Expanded instead of AspectRatio to avoid fractional overflow
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl == null || imageUrl!.isEmpty
                  ? Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 40),
                    )
                  : Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  _formatVnd(price),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatVnd(int p) {
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
