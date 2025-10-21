import 'package:get/get.dart';
import 'package:store_app/models/product.dart';

class WishlistController extends GetxController {
  final RxList<Product> _wishlist = <Product>[].obs;

  List<Product> get wishlist => _wishlist;

  void toggleFavorite(Product product) {
    if (_wishlist.contains(product)) {
      _wishlist.remove(product);
    } else {
      _wishlist.add(product);
    }
    update(); // rebuild các widget GetBuilder
  }

  bool isFavorite(Product product) {
    return _wishlist.contains(product);
  }

  void clearWishlist() {
    _wishlist.clear();
    update();
  }
}