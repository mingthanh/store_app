import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/models/product.dart';
import 'package:store_app/controllers/cart_controller.dart';
import 'package:store_app/controllers/api_auth_controller.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:store_app/repositories/order_api_repository.dart';
import 'package:store_app/view/qr_payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  // Lấy CartController an toàn: dùng instance đã đăng ký nếu có, nếu chưa thì khởi tạo
  final cart = Get.isRegistered<CartController>()
      ? Get.find<CartController>()
      : Get.put(CartController(), permanent: true);
  final apiAuth = Get.find<ApiAuthController>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'My cart',
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final items = cart.items.values.toList();
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) => _buildCartItem(
                  context,
                  items[index].product,
                  quantity: items[index].quantity,
                  onInc: () => cart.increment(items[index].product),
                  onDec: () => cart.decrement(items[index].product),
                  onRemove: () => cart.remove(items[index].product),
                ),
              );
            }),
          ),
          _buildCartSummary(context, cart, apiAuth),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, Product product, {int quantity = 1, VoidCallback? onInc, VoidCallback? onDec, VoidCallback? onRemove}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha((0.2 * 255).round())
                : Colors.grey.withAlpha((0.1 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(16)),
            child: (product.imageUrl.startsWith('http://') || product.imageUrl.startsWith('https://'))
                ? Image.network(
                    product.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    product.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        product.name,
                        style: AppTextStyles.withColor(
                          AppTextStyles.bodyLarge,
                          Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                      IconButton(
                        onPressed: () =>
                            _showDeleteConfirmationDialog(context, product, onRemove),
                        icon: const Icon(Icons.delete_outlined),
                        color: Colors.red[400],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price}',
                        style: AppTextStyles.withColor(
                          AppTextStyles.h3,
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: onDec,
                                icon: Icon(
                                  Icons.remove,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                )),
                            Text(
                              '$quantity',
                              style: AppTextStyles.withColor(
                                AppTextStyles.bodyLarge,
                                Theme.of(context).primaryColor,
                              ),
                            ),
                            IconButton(
                                onPressed: onInc,
                                icon: Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Product product, VoidCallback? onConfirm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[400]!.withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red[400],
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Remove Item',
              style: AppTextStyles.withColor(
                AppTextStyles.h3,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to remove this item from your cart?',
              textAlign: TextAlign.center,
              style: AppTextStyles.withColor(
                AppTextStyles.bodyMedium,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.black12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            )),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.withColor(
                            AppTextStyles.bodyMedium,
                            Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color!,
                          ),
                        ))),
                const SizedBox(width: 16),
                Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          onConfirm?.call();
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Remove',
                          style: AppTextStyles.withColor(
                            AppTextStyles.bodyMedium,
                            Colors.white,
                          ),
                        ))),
              ],
            )
          ],
        ),
      ),
      barrierColor: Colors.black54,
    );
  }

  Widget _buildCartSummary(BuildContext context, CartController cart, ApiAuthController auth) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                'Total (${cart.totalItems} items)',
                style: AppTextStyles.withColor(
                  AppTextStyles.bodyMedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              )),
              Obx(() => Text(
                '\$${cart.totalPrice.toStringAsFixed(2)}',
                style: AppTextStyles.withColor(
                  AppTextStyles.h2,
                  Theme.of(context).primaryColor,
                ),
              ))
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Chặn đặt hàng khi giỏ trống
                if (cart.totalItems == 0) {
                  Get.snackbar(
                    'Cart is empty',
                    'Please add some items before checkout',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
                if (!auth.isLoggedIn.value) {
                  Get.snackbar('Login required', 'Please sign in to place order', snackPosition: SnackPosition.BOTTOM);
                  return;
                }
                
                // Check if user has API token
                final token = auth.token.value;
                if (token == null || token.isEmpty) {
                  if (auth.isSocialLogin.value) {
                    Get.snackbar(
                      'Order not available', 
                      'Orders are currently only available for email/password accounts. Please create an account with email and password.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 4),
                    );
                  } else {
                    Get.snackbar('Authentication error', 'Please sign in again', snackPosition: SnackPosition.BOTTOM);
                  }
                  return;
                }
                
                // Thanh toán bằng VietQR QuickLink (mặc định và duy nhất)
                // Build order items and totals
                final items = cart.items.values.map((e) => {
                  'name': e.product.name,
                  'price': e.product.price,
                  'quantity': e.quantity,
                }).toList();
                final total = cart.totalPrice;
                // Convert to VND: assume price is in USD if < 1000
                const usdToVndRate = 24500.0;
                final amountVnd = (total < 1000 
                    ? (total * usdToVndRate) 
                    : total).round();
                try {
                  bool paid = false;
                  final orderId = 'qr-${DateTime.now().millisecondsSinceEpoch}';
                  // Mở màn QR và polling trạng thái
                  final r = await Get.to<bool>(() => QrPaymentScreen(orderId: orderId, amountVnd: amountVnd));
                  paid = r == true;
                  if (paid == true) {
                    // Hiển thị loading khi tạo đơn hàng
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false,
                    );
                    
                    try {
                      // Thanh toán thành công -> tạo đơn hàng tại API
                      await OrderApiRepository.instance.createOrder(
                        token,
                        {
                          'items': items,
                          'totalAmount': total,
                        },
                      );
                      
                      // Xóa giỏ hàng
                      cart.clearAndPersist();
                      
                      // Đóng loading
                      Get.back();
                      
                      // Hiển thị dialog thành công với animation
                      await Get.dialog(
                        Builder(
                          builder: (dialogContext) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            contentPadding: const EdgeInsets.all(24),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withAlpha((0.1 * 255).round()),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 48,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Đặt hàng thành công!',
                                  style: AppTextStyles.withColor(
                                    AppTextStyles.h3,
                                    Theme.of(dialogContext).textTheme.bodyLarge!.color!,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Đơn hàng của bạn đã được tạo và đang được xử lý.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.withColor(
                                    AppTextStyles.bodyMedium,
                                    Colors.grey[600]!,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => Get.back(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(dialogContext).primaryColor,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  child: Text(
                                    'Xem đơn hàng của tôi',
                                    style: AppTextStyles.withColor(
                                      AppTextStyles.bodyMedium,
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      );
                      
                      // Điều hướng đến My Orders (tab Account -> My Orders)
                      // Quay về MainScreen và chuyển sang tab Account (index 4)
                      Get.back(); // Đóng cart screen
                      // MainScreen sẽ tự động hiển thị, user có thể vào Account > My Orders
                      
                    } catch (orderError) {
                      Get.back(); // Đóng loading
                      Get.snackbar(
                        'Lỗi tạo đơn hàng',
                        orderError.toString().replaceFirst('Exception: ', ''),
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    }
                  } else {
                    Get.snackbar('Thanh toán bị hủy', 'Bạn đã hủy hoặc thanh toán thất bại', snackPosition: SnackPosition.BOTTOM);
                  }
                } catch (e) {
                  Get.snackbar('Checkout failed', e.toString().replaceFirst('Exception: ', ''), snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Proceed to Checkout',
                style: AppTextStyles.withColor(
                  AppTextStyles.buttonMedium,
                  Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}