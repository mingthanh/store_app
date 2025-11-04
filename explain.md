# Store App — Tóm tắt ngắn gọn

Ứng dụng thương mại điện tử đa nền tảng (Flutter) với backend Node.js + MongoDB, tích hợp Firebase và dịch vụ bản đồ/QR.

## 1) Kiến trúc nhanh
- Flutter + GetX (Controllers, Routing, DI)
- Repository cho API, Services cho Firebase
- Lưu trữ: Firestore (cloud), GetStorage (local key–value)
- Thư mục chính: controllers/ models/ repositories/ services/ utils/ view/ widgets

## 2) Dịch vụ & gói chính
- Firebase: firebase_core, firebase_auth (Email/Google/Facebook), cloud_firestore (users/products/orders)
- Bản đồ & vị trí: google_maps_flutter, geolocator
- QR: mobile_scanner (quét), qr_flutter (tạo mã)
- UI/UX: cached_network_image, shimmer, lottie, intl
- State & lưu cục bộ: get, get_storage

## 3) API backend (Node.js/Express)
- Auth: POST /api/auth/register, POST /api/auth/login
- Orders (API): tạo đơn, đơn của tôi, tất cả đơn (admin), cập nhật trạng thái
- Tracking: POST /api/tracking/scan, GET /api/tracking/:trackingId, GET /api/tracking/order/:orderId
- Payment: VietQR QuickLink + Casso webhook (xử lý ở server)

API base URL có thể ghi đè: --dart-define=API_BASE_URL=http://<ip>:3000

## 4) Tính năng chính
- Khách hàng: duyệt sản phẩm, giỏ hàng, thanh toán QR, theo dõi đơn trên bản đồ, lịch sử đơn, cài đặt
- Quản trị: dashboard, CRUD sản phẩm, duyệt/cập nhật đơn, tracking, quét QR
- Điều hướng: Splash → Onboarding (1 lần) → Sign in/up → Main; logout → Signin (không lặp onboarding)

## 5) Màn hình tiêu biểu (lib/view)
- splash_screen, on_boarding_screen, signin_screen, sign_up_screen, main_screen, home_screen
- all_products_screen, product_details_screen, cart_screen
- qr_scanner_screen, order_qr_display_screen, order_tracking_screen, tracking_input_screen
- settings_screen, notifications_screen, wishlist_screen (nếu có)
- admin_dashboard_api_screen, admin_dashboard_screen

## 6) Mã nguồn quan trọng
- Controllers: AuthController, ApiAuthController, CartController, WishlistController, ThemeController, LanguageController
- Services: AuthService (Firebase), FirestoreService
- Repositories: ApiService, ApiAuthService, ProductRepository, OrderApiRepository, TrackingRepository
- Utils: app_textstyles.dart, format.dart (VND), shopping_utils.dart, tracking_helper.dart

## 7) Cách chạy nhanh
- Backend: vào server → npm i → npm run dev (MongoDB local, PORT 3000)
- App: flutter pub get → flutter run (có thể -d chrome cho web)
- Yêu cầu: Google Maps API key, google-services.json (Firebase)

## 8) Lưu ý quan trọng
- Social login để trải nghiệm; đặt hàng qua API yêu cầu email/password (xem ShoppingUtils)
- GetStorage: api_token, cart_<userId>, wishlist_<userId>, locale, theme
- Firestore: users, products, orders (stream + thống kê cho admin)

## 9) Tài liệu tham khảo trong repo
- README_admin_api.md (API admin)
- PAYMENT_INTEGRATION.md (thanh toán)
- check_user_role.mongodb.js (kiểm tra role)

## 10) Thư mục & tác dụng (quick guide)
- lib/: mã nguồn ứng dụng Flutter
	- controllers/: GetX controllers (quản lý state, luồng nghiệp vụ, điều hướng)
	- models/: mô hình dữ liệu/domain (Product, Order, TrackingHistory…)
	- repositories/: gọi REST API, tách tầng dữ liệu, parse JSON (Auth, Orders, Products, Tracking…)
	- services/: tích hợp dịch vụ (Firebase Auth/Firestore/Storage…), logic làm việc với SDK bên thứ ba
	- utils/: tiện ích dùng lại (format, theme, i18n, helpers)
		- app_textstyles.dart: định nghĩa font & text styles
		- app_themes.dart: theme sáng/tối
		- translations.dart: i18n EN/VI
		- format.dart: định dạng tiền VNĐ/số rút gọn
		- shopping_utils.dart: kiểm tra quyền mua hàng, thông báo hướng dẫn
		- tracking_helper.dart: validate/format/generate thông tin tracking
	- view/: các màn hình UI (pages), điều hướng bằng GetX
	- widgets/: component tái sử dụng (product_card, product_grid, filter…)
	- features/: module theo tính năng (orders, my_orders, profile…) có thể chứa model/repository/view riêng
- assets/: ảnh, biểu tượng, hoạt họa (lottie)
- server/: mã nguồn backend Node.js/Express (routes, controllers, models)
- test/: unit/widget tests
- android/ios/web/macos/windows/linux/: cấu hình từng nền tảng
- build/, coverage/: thư mục sinh ra khi build/test (có thể bỏ qua khi đọc mã nguồn)
