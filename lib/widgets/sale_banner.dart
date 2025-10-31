import 'package:flutter/material.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:get/get.dart';
import 'package:store_app/view/all_products_screen.dart';

class SaleBanner extends StatelessWidget {
  const SaleBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Text & CTA section ---
          Text(
            'Get Your',
            style: AppTextStyles.withColor(
              AppTextStyles.h3,
              Colors.white,
            ),
          ),
          const SizedBox(height: 6),

          // Row chứa Special Discount + nút Shop Now
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Special Discount',
                  style: AppTextStyles.withColor(
                    AppTextStyles.withWeight(AppTextStyles.h2, FontWeight.bold),
                    Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                ),
                onPressed: () {
                  Get.to(() => const AllProductsScreen());
                },
                child: const Text(
                  'Shop Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Text giảm giá (đặt dưới Special Discount để dễ đọc)
          Text(
            'Up to 30% Off',
            style: AppTextStyles.withColor(
              AppTextStyles.withWeight(AppTextStyles.h3, FontWeight.w600),
              Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // --- Image section ---
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/banner.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}