import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/controllers/auth_controller.dart';
import 'package:store_app/controllers/cart_controller.dart';
import 'package:store_app/controllers/wishlist_controller.dart';
import 'package:store_app/models/product.dart';

class DataIsolationTestPage extends StatelessWidget {
  const DataIsolationTestPage({super.key});

  // Test products
  static final product1 = Product(
    id: 1,
    name: 'Facebook Test Product',
    category: 'Men',
    price: 100.0,
    imageUrl: 'https://picsum.photos/200/200?random=1',
    description: 'Product for Facebook user',
  );

  static final product2 = Product(
    id: 2,
    name: 'Google Test Product',
    category: 'Women',
    price: 200.0,
    imageUrl: 'https://picsum.photos/200/200?random=2',
    description: 'Product for Google user',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Isolation Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🔬 Test Data Isolation Between Users',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Current Status
            GetBuilder<AuthController>(
              builder: (auth) => GetBuilder<CartController>(
                builder: (cart) => GetBuilder<WishlistController>(
                  builder: (wishlist) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current User: ${auth.userId.value ?? "None"}'),
                          Text('Cart Items: ${cart.totalItems}'),
                          Text('Wishlist Items: ${wishlist.wishlist.length}'),
                          if (cart.items.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text('Cart Contents:', style: TextStyle(fontWeight: FontWeight.bold)),
                            ...cart.items.values.map((item) => 
                              Text('  • ${item.product.name} (x${item.quantity})')
                            ),
                          ],
                          if (wishlist.wishlist.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text('Wishlist Contents:', style: TextStyle(fontWeight: FontWeight.bold)),
                            ...wishlist.wishlist.map((product) => 
                              Text('  • ${product.name}')
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Test Buttons
            ElevatedButton.icon(
              onPressed: () => _simulateFacebookUser(),
              icon: const Icon(Icons.facebook),
              label: const Text('Simulate Facebook User'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: () => _simulateGoogleUser(),
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Simulate Google User'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: () => _addTestItems(),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add Test Items'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: () => _clearCurrentUserData(),
              icon: const Icon(Icons.clear),
              label: const Text('Clear Current User Data'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700]),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: () => _logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Logout (Clear All)'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateFacebookUser() {
    const facebookUserId = 'facebook_user_12345';
    
    final auth = Get.find<AuthController>();
    final cart = Get.find<CartController>();
    final wishlist = Get.find<WishlistController>();
    
    // Set user ID and load data
    auth.userId.value = facebookUserId;
    cart.loadUserCart(facebookUserId);
    wishlist.loadUserWishlist(facebookUserId);
    
    Get.snackbar(
      '👤 Facebook User',
      'Switched to Facebook user: $facebookUserId',
      backgroundColor: Colors.blue[100],
    );
  }

  void _simulateGoogleUser() {
    const googleUserId = 'google_user_67890';
    
    final auth = Get.find<AuthController>();
    final cart = Get.find<CartController>();
    final wishlist = Get.find<WishlistController>();
    
    // Set user ID and load data
    auth.userId.value = googleUserId;
    cart.loadUserCart(googleUserId);
    wishlist.loadUserWishlist(googleUserId);
    
    Get.snackbar(
      '👤 Google User',
      'Switched to Google user: $googleUserId',
      backgroundColor: Colors.red[100],
    );
  }

  void _addTestItems() {
    final auth = Get.find<AuthController>();
    final cart = Get.find<CartController>();
    final wishlist = Get.find<WishlistController>();
    
    final currentUserId = auth.userId.value;
    if (currentUserId == null) {
      Get.snackbar('Error', 'Please select a user first');
      return;
    }
    
    // Add different products based on user
    if (currentUserId.contains('facebook')) {
      cart.add(product1, qty: 2);
      wishlist.toggleFavorite(product1);
      Get.snackbar(
        '🛒 Added Items',
        'Added Facebook test product to cart (x2) and wishlist',
        backgroundColor: Colors.green[100],
      );
    } else if (currentUserId.contains('google')) {
      cart.add(product2, qty: 1);
      wishlist.toggleFavorite(product2);
      Get.snackbar(
        '🛒 Added Items',
        'Added Google test product to cart (x1) and wishlist',
        backgroundColor: Colors.green[100],
      );
    }
  }

  void _clearCurrentUserData() {
    final cart = Get.find<CartController>();
    final wishlist = Get.find<WishlistController>();
    
    cart.items.clear();
    cart.items.refresh();
    wishlist.clearWishlist();
    
    Get.snackbar(
      '🗑️ Cleared',
      'Cleared current user data',
      backgroundColor: Colors.orange[100],
    );
  }

  void _logout() {
    final auth = Get.find<AuthController>();
    final cart = Get.find<CartController>();
    final wishlist = Get.find<WishlistController>();
    
    // Simulate logout - clear everything
    auth.userId.value = null;
    cart.clearUserData();
    wishlist.clearUserData();
    
    Get.snackbar(
      '👋 Logged Out',
      'All user data cleared',
      backgroundColor: Colors.grey[100],
    );
  }
}