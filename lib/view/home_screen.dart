import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/controllers/theme_controller.dart';
import 'package:store_app/view/all_products_screen.dart';
import 'package:store_app/view/widgets/category_chips.dart';
import 'package:store_app/view/widgets/custom_search_bar.dart';
import 'package:store_app/view/widgets/product_grid.dart';
import 'package:store_app/view/widgets/sale_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/images/avatar.jpg'),
                  ),
                  const SizedBox(width: 12),

                  // Greeting texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hello, Quái Vật Hồ Lockness!',
                          overflow: TextOverflow.ellipsis, // tránh tràn dòng
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
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

                  // Notification icon
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined),
                  ),

                  // Cart button
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_bag_outlined),
                  ),

                  // Theme toggle button
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
            // search bar
            const CustomSearchBar(),

            // categories chip list
            const CategoryChips(),

            // sales banner
            const SaleBanner(),

            // popular products 
            Padding(
              padding: EdgeInsets.symmetric(
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
                      onTap: () => Get.to(()=> const AllProductsScreen()),
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
              child: ProductGrid(),
            ),
          ],
        ),
      ),
    );
  }
}
