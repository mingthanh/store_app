/// Mô hình dữ liệu đại diện cho một sản phẩm trong cửa hàng
/// Chứa tất cả thông tin cần thiết để hiển thị và quản lý sản phẩm
class Product {
  final int id; // ID duy nhất của sản phẩm
  final String name; // Tên sản phẩm
  final String category; // Danh mục sản phẩm
  final double price; // Giá hiện tại
  final double? oldPrice; // Giá cũ (cho việc hiển thị giảm giá)
  final String imageUrl; // URL hình ảnh sản phẩm
  final bool isFavorite; // Trạng thái yêu thích
  final String description; // Mô tả chi tiết sản phẩm

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

  // So sánh hai sản phẩm dựa trên ID
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Danh sách mẫu các sản phẩm để demo ứng dụng
/// Chứa thông tin về các sản phẩm giày thể thao Air Jordan
final List<Product> products = [
  const Product(
    id: 1,
    name: 'Air Jordan 1 Mid',
    category: 'Women',
    price: 138.34,     // Giá hiện tại USD
    oldPrice: 189.00,  // Giá cũ USD
    imageUrl: 'assets/images/shoe.jpg',
    description:
        'Không bao giờ làm hỏng một tác phẩm kinh điển. Giữ di sản trên đôi chân của bạn với phong cách trắng toàn tập sẽ không bao giờ lỗi thời.',
  ),
  const Product(
    id: 2,
    name: 'Air Jordan 1 Low',
    category: 'Men',
    price: 145.99,
    oldPrice: 189.00,
    imageUrl: 'assets/images/shoe2.jpg',
    description:
        'Được lấy cảm hứng từ bản gốc ra mắt năm 1985, Air Jordan 1 Low mang đến vẻ ngoài sạch sẽ, cổ điển quen thuộc nhưng luôn mới mẻ.',
  ),
  const Product(
    id: 3,
    name: 'Air Jordan 1 Low SE',
    category: 'Girls',
    price: 132.50,
    oldPrice: 179.00,
    imageUrl: 'assets/images/shoes2.jpg',
    description:
        'Đôi giày thể thao luôn tỏa sáng với thái độ bắt mắt tươi mới.',
  ),
  const Product(
    id: 4,
    name: 'Air Jordan 1 Mid',
    category: 'Women',
    price: 149.00,
    oldPrice: 199.00,
    imageUrl: 'assets/images/shoes3.jpg',
    description:
        'Không bao giờ làm hỏng một tác phẩm kinh điển. Giữ di sản trên đôi chân của bạn với phong cách trắng toàn tập sẽ không bao giờ lỗi thời.',
  ),
];
