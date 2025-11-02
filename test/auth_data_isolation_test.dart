import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_app/controllers/auth_controller.dart';
import 'package:store_app/controllers/cart_controller.dart';
import 'package:store_app/controllers/wishlist_controller.dart';
import 'package:store_app/models/product.dart';

void main() {
  group('Auth Data Isolation Tests', () {
    late CartController cartController;
    late WishlistController wishlistController;

    // Mock products for testing
    final product1 = Product(
      id: 1,
      name: 'Test Product 1',
      category: 'Men',
      price: 100.0,
      imageUrl: 'https://example.com/1.jpg',
      description: 'Test description 1',
    );

    final product2 = Product(
      id: 2,
      name: 'Test Product 2',
      category: 'Women',
      price: 200.0,
      imageUrl: 'https://example.com/2.jpg',
      description: 'Test description 2',
    );

    setUp(() async {
      // Initialize GetStorage for testing
      await GetStorage.init();
      
      // Clean up any existing registrations
      if (Get.isRegistered<AuthController>()) Get.delete<AuthController>();
      if (Get.isRegistered<CartController>()) Get.delete<CartController>();
      if (Get.isRegistered<WishlistController>()) Get.delete<WishlistController>();

      // Register controllers
      Get.put(AuthController());
      cartController = Get.put(CartController());
      wishlistController = Get.put(WishlistController());
    });

    tearDown(() {
      // Clean up storage and controllers
      GetStorage().erase();
      Get.deleteAll();
    });

    test('Cart data should be isolated between different users', () {
      // Simulate Facebook user login
      const facebookUserId = 'facebook_user_123';
      cartController.loadUserCart(facebookUserId);
      
      // Add product to Facebook user's cart
      cartController.add(product1);
      expect(cartController.totalItems, 1);
      expect(cartController.items.containsKey(product1.id), true);
      
      // Simulate logout and Google user login
      cartController.clearUserData();
      expect(cartController.totalItems, 0);
      expect(cartController.items.isEmpty, true);
      
      const googleUserId = 'google_user_456';
      cartController.loadUserCart(googleUserId);
      
      // Google user should have empty cart
      expect(cartController.totalItems, 0);
      expect(cartController.items.isEmpty, true);
      
      // Add different product to Google user's cart
      cartController.add(product2);
      expect(cartController.totalItems, 1);
      expect(cartController.items.containsKey(product2.id), true);
      expect(cartController.items.containsKey(product1.id), false);
      
      // Switch back to Facebook user - should restore original cart
      cartController.loadUserCart(facebookUserId);
      expect(cartController.totalItems, 1);
      expect(cartController.items.containsKey(product1.id), true);
      expect(cartController.items.containsKey(product2.id), false);
    });

    test('Wishlist data should be isolated between different users', () {
      // Simulate Facebook user login
      const facebookUserId = 'facebook_user_123';
      wishlistController.loadUserWishlist(facebookUserId);
      
      // Add product to Facebook user's wishlist
      wishlistController.toggleFavorite(product1);
      expect(wishlistController.wishlist.length, 1);
      expect(wishlistController.isFavorite(product1), true);
      
      // Simulate logout and Google user login
      wishlistController.clearUserData();
      expect(wishlistController.wishlist.length, 0);
      
      const googleUserId = 'google_user_456';
      wishlistController.loadUserWishlist(googleUserId);
      
      // Google user should have empty wishlist
      expect(wishlistController.wishlist.length, 0);
      expect(wishlistController.isFavorite(product1), false);
      
      // Add different product to Google user's wishlist
      wishlistController.toggleFavorite(product2);
      expect(wishlistController.wishlist.length, 1);
      expect(wishlistController.isFavorite(product2), true);
      expect(wishlistController.isFavorite(product1), false);
      
      // Switch back to Facebook user - should restore original wishlist
      wishlistController.loadUserWishlist(facebookUserId);
      expect(wishlistController.wishlist.length, 1);
      expect(wishlistController.isFavorite(product1), true);
      expect(wishlistController.isFavorite(product2), false);
    });

    test('Data persistence across app restarts', () async {
      const userId = 'persistent_user_789';
      
      // First session: Add items to cart and wishlist
      cartController.loadUserCart(userId);
      wishlistController.loadUserWishlist(userId);
      
      cartController.add(product1, qty: 2);
      cartController.add(product2, qty: 1);
      wishlistController.toggleFavorite(product1);
      
      expect(cartController.totalItems, 3);
      expect(wishlistController.wishlist.length, 1);
      
      // Simulate app restart: recreate controllers
      Get.delete<CartController>();
      Get.delete<WishlistController>();
      
      final newCartController = Get.put(CartController());
      final newWishlistController = Get.put(WishlistController());
      
      // Load same user data - should restore from storage
      newCartController.loadUserCart(userId);
      newWishlistController.loadUserWishlist(userId);
      
      expect(newCartController.totalItems, 3);
      expect(newCartController.items.containsKey(product1.id), true);
      expect(newCartController.items.containsKey(product2.id), true);
      expect(newCartController.items[product1.id]?.quantity, 2);
      expect(newCartController.items[product2.id]?.quantity, 1);
      
      expect(newWishlistController.wishlist.length, 1);
      expect(newWishlistController.isFavorite(product1), true);
    });
  });
}