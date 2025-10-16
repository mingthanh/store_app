class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  final bool isFavorite;
  final String description;

  const Product({
    required this.id,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.oldPrice,
    this.isFavorite = false,
  });
}

final List<Product> products = [
  const Product(
    id: 1,
    name: 'Air Jordan 1 Mid',
    category: 'Women',
    price: 138.34,     // Giá hiện tại USD
    oldPrice: 189.00,  // Giá cũ USD
    imageUrl: 'assets/images/shoe.jpg',
    description:
        'Never mess with a classic. Keep heritage on your feet with a white-on-white look that will never go out of style.',
  ),
  const Product(
    id: 2,
    name: 'Air Jordan 1 Low',
    category: 'Men',
    price: 145.99,
    oldPrice: 189.00,
    imageUrl: 'assets/images/shoe2.jpg',
    description:
        'Inspired by the original that debuted in 1985, the Air Jordan 1 Low offers a clean, classic look that is familiar yet always fresh.',
  ),
  const Product(
    id: 3,
    name: 'Air Jordan 1 Low SE',
    category: 'Girls',
    price: 132.50,
    oldPrice: 179.00,
    imageUrl: 'assets/images/shoes2.jpg',
    description:
        'The sneaker that always steps out with a fresh blast of eye-catching attitude.',
  ),
  const Product(
    id: 4,
    name: 'Air Jordan 1 Mid',
    category: 'Women',
    price: 149.00,
    oldPrice: 199.00,
    imageUrl: 'assets/images/shoes3.jpg',
    description:
        'Never mess with a classic. Keep heritage on your feet with a white-on-white look that will never go out of style.',
  ),
];
