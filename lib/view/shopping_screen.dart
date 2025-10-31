import 'package:flutter/material.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:store_app/widgets/category_chips.dart';
import 'package:store_app/widgets/filter_bottom_sheet.dart';
import 'package:store_app/widgets/product_grid.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  // 0=All, 1=Men, 2=Women, 3=Girls
  int selected = 0; // trạng thái filter danh mục

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
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16),
            // CategoryChips ở đây chạy dạng controlled: cha truyền selectedIndex và nhận onChanged
            child: CategoryChips(
              selectedIndex: selected,
              onChanged: (i) => setState(() => selected = i),
            ),
          ),
          Expanded(
            child: ProductGrid(
              useApi: true,
              // Map chỉ mục -> category string; 0=All => null để API trả toàn bộ
              category: switch (selected) {
                1 => 'Men',
                2 => 'Women',
                3 => 'Girls',
                _ => null,
              },
            ),
          )
        ],
      ),
    );
  }
}
