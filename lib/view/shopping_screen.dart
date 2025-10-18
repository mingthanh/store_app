import 'package:flutter/material.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:store_app/view/widgets/category_chips.dart';
import 'package:store_app/view/widgets/filter_bottom_sheet.dart';
import 'package:store_app/view/widgets/product_grid.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Shopping',
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
            onPressed: () => FilterBottomSheet.show(context),
            icon: const Icon(Icons.filter_list),
            color: isDark ? Colors.white : Colors.black,
          ),
        ],
      ),
      body: Column(
        children: const [
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: CategoryChips(),
          ),
          Expanded(child: ProductGrid(useLocal: true))
        ],
      ),
    );
  }
}
