# Store App - Phân tích Codebase và Chức năng

## Tổng quan dự án
Đây là một ứng dụng Flutter để xây dựng cửa hàng trực tuyến (e-commerce) với backend Node.js và sử dụng Firebase làm dịch vụ đám mây.

## ⭐ LOGIC ĐIỀU HƯỚNG MỚI - Onboarding thông minh

### 🔄 Flow điều hướng hiện tại:

```
1. App khởi động → SplashScreen (2.5s)

2. SplashScreen kiểm tra theo thứ tự:
   ✅ Nếu đã đăng nhập (isLoggedIn = true) → MainScreen
   ✅ Nếu lần đầu mở app (isFirstTime = true) → OnboardingScreen
   ✅ Nếu đã logout (isLoggedIn = false, isFirstTime = false) → SigninScreen

3. OnboardingScreen:
   - Skip/Get Started → setFirstTimeDone() + SigninScreen

4. SigninScreen:
   - Đăng nhập thành công → setFirstTimeDone() + MainScreen
   - Đăng ký thành công → setFirstTimeDone() + MainScreen  
   - Social login thành công → setFirstTimeDone() + MainScreen

5. Logout:
   - isLoggedIn = false (KHÔNG reset isFirstTime)
   - Lần sau mở app: SplashScreen → SigninScreen (bỏ qua onboarding)
```

### 🎯 Ưu điểm của logic mới:
- **Onboarding chỉ hiện 1 lần** cho người dùng mới
- **Logout thì quay về SigninScreen** không qua onboarding
- **Trải nghiệm mượt mà** cho người dùng quay lại

## Cấu trúc thư mục chính

### 1. Thư mục `lib/` - Mã nguồn Flutter chính

#### **Main Files**
- **[main.dart](lib/main.dart)**: Entry point của ứng dụng, khởi tạo Firebase và MaterialApp
- **[firebase_options.dart](lib/firebase_options.dart)**: Cấu hình Firebase cho các platform khác nhau

#### **Controllers** - Quản lý trạng thái ứng dụng
- **[auth_controller.dart](lib/controllers/auth_controller.dart)**: Quản lý xác thực người dùng (đăng nhập, đăng ký, đăng xuất)
- **[banner_controller.dart](lib/controllers/banner_controller.dart)**: Quản lý banner quảng cáo
- **[cart_controller.dart](lib/controllers/cart_controller.dart)**: Quản lý giỏ hàng (thêm, xóa, cập nhật sản phẩm)
- **[category_controller.dart](lib/controllers/category_controller.dart)**: Quản lý danh mục sản phẩm
- **[order_controller.dart](lib/controllers/order_controller.dart)**: Quản lý đơn hàng
- **[product_controller.dart](lib/controllers/product_controller.dart)**: Quản lý sản phẩm
- **[subcategory_controller.dart](lib/controllers/subcategory_controller.dart)**: Quản lý danh mục con

#### **Features** - Các tính năng chính của ứng dụng
- **Authentication**:
  - [login_screen.dart](lib/features/authentication/login_screen.dart): Màn hình đăng nhập
  - [registration_screen.dart](lib/features/authentication/registration_screen.dart): Màn hình đăng ký
  - [forgot_password_screen.dart](lib/features/authentication/forgot_password_screen.dart): Quên mật khẩu

- **Home/Main**:
  - [main_screen.dart](lib/features/home/main_screen.dart): Màn hình chính với bottom navigation
  - [home_screen.dart](lib/features/home/home_screen.dart): Trang chủ hiển thị sản phẩm
  - [store_screen.dart](lib/features/home/store_screen.dart): Màn hình cửa hàng

- **Shop**:
  - [all_products.dart](lib/features/shop/all_products.dart): Hiển thị tất cả sản phẩm
  - [product_details.dart](lib/features/shop/product_details.dart): Chi tiết sản phẩm
  - [cart.dart](lib/features/shop/cart.dart): Giỏ hàng
  - [checkout.dart](lib/features/shop/checkout.dart): Thanh toán

- **Personalization**:
  - [profile.dart](lib/features/personalization/profile.dart): Thông tin cá nhân
  - [user_address.dart](lib/features/personalization/user_address.dart): Địa chỉ người dùng
  - [settings.dart](lib/features/personalization/settings.dart): Cài đặt

#### **Models** - Mô hình dữ liệu
- **[banner_model.dart](lib/models/banner_model.dart)**: Model cho banner quảng cáo
- **[cart_model.dart](lib/models/cart_model.dart)**: Model cho giỏ hàng
- **[category_model.dart](lib/models/category_model.dart)**: Model cho danh mục
- **[order_model.dart](lib/models/order_model.dart)**: Model cho đơn hàng
- **[product_model.dart](lib/models/product_model.dart)**: Model cho sản phẩm
- **[user_model.dart](lib/models/user_model.dart)**: Model cho người dùng

#### **Services** - Dịch vụ tích hợp
- **[firebase_auth_service.dart](lib/services/firebase_auth_service.dart)**: Dịch vụ xác thực Firebase
- **[firestore_service.dart](lib/services/firestore_service.dart)**: Dịch vụ Firestore database
- **[storage_service.dart](lib/services/storage_service.dart)**: Dịch vụ lưu trữ Firebase Storage

#### **Repositories** - Tầng truy cập dữ liệu
- **[auth_repository.dart](lib/repositories/auth_repository.dart)**: Repository cho xác thực
- **[banner_repository.dart](lib/repositories/banner_repository.dart)**: Repository cho banner
- **[category_repository.dart](lib/repositories/category_repository.dart)**: Repository cho danh mục
- **[order_repository.dart](lib/repositories/order_repository.dart)**: Repository cho đơn hàng
- **[product_repository.dart](lib/repositories/product_repository.dart)**: Repository cho sản phẩm

#### **Utils** - Tiện ích và helper
- **[constants.dart](lib/utils/constants.dart)**: Các hằng số toàn cục
- **[validators.dart](lib/utils/validators.dart)**: Validation cho form
- **[helpers.dart](lib/utils/helpers.dart)**: Các hàm tiện ích
- **[theme.dart](lib/utils/theme.dart)**: Theme và styling

#### **Widgets** - Component tái sử dụng
- **[custom_button.dart](lib/widgets/custom_button.dart)**: Button tùy chỉnh
- **[product_card.dart](lib/widgets/product_card.dart)**: Card hiển thị sản phẩm
- **[loading_widget.dart](lib/widgets/loading_widget.dart)**: Widget loading

### 2. Thư mục `server/` - Backend Node.js

#### **Cấu trúc Server**
- **[package.json](server/package.json)**: Dependencies và scripts cho server
- **[.env](server/.env)**: Biến môi trường (database, API keys)
- **[src/](server/src/)**: Mã nguồn server

#### **Các thành phần chính**
- **Routes**: Định nghĩa API endpoints
- **Controllers**: Xử lý business logic
- **Models**: Mô hình dữ liệu database
- **Middleware**: Authentication, validation
- **Utils**: Helper functions

### 3. Firebase Services được sử dụng

#### **Firebase Authentication**
- Đăng ký/đăng nhập bằng email & password
- Đăng nhập bằng Google
- Đăng nhập bằng Facebook
- Reset password
- Email verification

#### **Cloud Firestore**
- Lưu trữ thông tin người dùng
- Quản lý sản phẩm và danh mục
- Lưu trữ đơn hàng
- Lịch sử giao dịch

#### **Firebase Storage**
- Lưu trữ hình ảnh sản phẩm
- Avatar người dùng
- File uploads

#### **Firebase Cloud Messaging (FCM)**
- Push notifications
- Thông báo đơn hàng
- Thông báo khuyến mãi

### 4. APIs và Integrations

#### **Payment APIs**
- Stripe Payment Gateway
- PayPal Integration
- Local payment methods

#### **Shipping APIs**
- GHN (Giao Hàng Nhanh)
- Viettel Post
- Vietnam Post

#### **Social Login**
- Google Sign-in API
- Facebook Login API

#### **Maps & Location**
- Google Maps API
- Location services

### 5. Features chính của ứng dụng

#### **User Management**
- Đăng ký/đăng nhập
- Quản lý profile
- Địa chỉ giao hàng
- Lịch sử đơn hàng

#### **Product Management**
- Browse sản phẩm theo danh mục
- Tìm kiếm và filter
- Xem chi tiết sản phẩm
- Đánh giá và review

#### **Shopping Cart**
- Thêm/xóa sản phẩm
- Cập nhật số lượng
- Lưu giỏ hàng
- Wishlist

#### **Order Management**
- Đặt hàng
- Theo dõi đơn hàng
- Lịch sử mua hàng
- Hủy đơn hàng

#### **Payment & Shipping**
- Multiple payment methods
- Shipping address management
- Order tracking
- Delivery notifications

### 6. Testing

#### **Test Files**
- **[widget_test.dart](test/widget_test.dart)**: Widget testing
- **[auth_data_isolation_test.dart](test/auth_data_isolation_test.dart)**: Authentication testing

### 7. Platform Support

#### **Android**
- [build.gradle.kts](android/build.gradle.kts): Android build configuration
- [google-services.json](android/app/google-services.json): Firebase config

#### **iOS**
- Xcode project configuration
- iOS-specific Firebase setup

#### **Web**
- [index.html](web/index.html): Web entry point
- PWA support

#### **Desktop**
- Windows, macOS, Linux support
- CMake configuration

### 8. Development Tools

#### **Dependencies (pubspec.yaml)**
- **UI**: Material Design, Cupertino
- **State Management**: GetX
- **Networking**: HTTP, Dio
- **Database**: Firestore, SQLite
- **Authentication**: Firebase Auth
- **Storage**: Shared Preferences, Secure Storage
- **Images**: Cached Network Image
- **Animations**: Lottie
- **QR Code**: QR Code Scanner

#### **Dev Dependencies**
- Flutter Lints
- Build Runner
- JSON Annotation
- Testing frameworks

## Tóm tắt
Đây là một ứng dụng e-commerce hoàn chỉnh được xây dựng bằng Flutter với backend Node.js, sử dụng Firebase làm dịch vụ đám mây chính. Ứng dụng hỗ trợ đa nền tảng (Android, iOS, Web, Desktop) với đầy đủ tính năng của một cửa hàng trực tuyến modern.