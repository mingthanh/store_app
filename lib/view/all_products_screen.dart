import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:store_app/widgets/filter_bottom_sheet.dart';
import 'package:store_app/widgets/product_grid.dart';
import 'package:store_app/widgets/category_filter_bar.dart';

/// Màn hình hiển thị tất cả sản phẩm
///
/// - Cho phép lọc theo danh mục (All/Men/Women/Girls)
/// - Hỗ trợ mở bộ lọc nâng cao ở bottom sheet (FilterBottomSheet)
/// - Danh sách sản phẩm hiển thị bằng [ProductGrid] (có thể dùng API hoặc Firestore)
class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  /// Danh mục đang được chọn để lọc (mặc định: 'All')
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'All Products',
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          // Search icon
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            color: isDark ? Colors.white : Colors.black,
          ),

          // Filter icon
          IconButton(
            onPressed: () async {
              final Map<String, dynamic>? res = await FilterBottomSheet.show(context);
              if (!mounted || res == null) return;
              final String? cat = res['category'] as String?;
              if (cat != null && cat.isNotEmpty) {
                setState(() {
                  _selectedCategory = cat;
                });
              }
            },
            icon: const Icon(Icons.filter_list),
            color: isDark ? Colors.white : Colors.black,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryFilterBar(
            categories: const ['All', 'Men', 'Women', 'Girls'],
            selected: _selectedCategory,
            onChanged: (val) {
              setState(() => _selectedCategory = val);
            },
          ),
          Expanded(
            child: ProductGrid(
              useApi: true,
              category: _selectedCategory == 'All' ? null : _selectedCategory,
            ),
          ),
        ],
      ),
    );
  }
}