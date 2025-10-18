import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/controllers/theme_controller.dart';
import 'package:store_app/view/all_products_screen.dart';
import 'package:store_app/view/cart_screen.dart';
import 'package:store_app/view/widgets/category_chips.dart';
import 'package:store_app/view/widgets/custom_search_bar.dart';
import 'package:store_app/view/widgets/product_grid.dart';
import 'package:store_app/view/widgets/sale_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
  // final isDark = Theme.of(context).brightness == Brightness.dark; // not used here

    return SafeArea(
      child: Column(
        children: [
            // 🧑 Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/images/avatar.jpg'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hello, Quái Vật Hồ Lockness!',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        Text(
                          'Hope you’re having a great day!',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                  IconButton(
                    onPressed: () => Get.to(() => const CartScreen()),
                    icon: const Icon(Icons.shopping_bag_outlined),
                  ),
                  GetBuilder<ThemeController>(
                    builder: (controller) => IconButton(
                      onPressed: controller.toggleTheme,
                      icon: Icon(
                        controller.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔍 Search bar
            const CustomSearchBar(),

            // 🏷️ Category chips
            const CategoryChips(),

            // sales banner
            const SaleBanner(),

            // popular products 
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16, 
                vertical: 8
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        // color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Xử lý sự kiện khi người dùng nhấn vào "See All"
                        Get.to(() => const AllProductsScreen());
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
            ),

            // products grid
            const Expanded(
              child: ProductGrid(useLocal: true),
            ),
          ],
        ),
    );
  }
}
