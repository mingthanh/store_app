# 🛍️ Store App

Đây là **đồ án môn học: Lập trình trên thiết bị di động**, được xây dựng bằng **Flutter**.

## 🧩 Giới thiệu

Ứng dụng **Store App** là một ứng dụng mua sắm trực tuyến mẫu, giúp người dùng:
- Xem danh sách sản phẩm
- Xem chi tiết từng sản phẩm
- Thêm sản phẩm vào giỏ hàng
- (Tùy chọn) Thanh toán hoặc quản lý tài khoản người dùng

Mục tiêu của dự án là **nắm vững quy trình phát triển ứng dụng Flutter đa nền tảng** (Android, iOS, Web, Desktop).

## ⚙️ Công nghệ sử dụng
- **Flutter** (Dart)
- **Provider / GetX / Bloc** (tuỳ theo kiến trúc bạn chọn)
- **Firebase / REST API** (nếu có kết nối backend)
- **Material Design** cho giao diện

## 🚀 Cách chạy dự án

1. Cài đặt Flutter (nếu chưa có):  
   👉 [Hướng dẫn cài đặt Flutter](https://docs.flutter.dev/get-started/install)

2. Clone dự án:
   ```bash
   git clone https://github.com/mingthanh/store_app.git

## Facebook Login integration

This app includes optional "Login with Facebook" using `flutter_facebook_auth`.

Setup steps:

1) Create a Facebook App at https://developers.facebook.com/apps and enable Facebook Login (Android, iOS, Web).

2) Replace placeholders with your real values:
   - `lib/utils/app_secrets.dart`: `facebookAppId`, `facebookClientToken`.
   - `android/app/src/main/res/values/strings.xml`: `facebook_app_id`, `facebook_client_token`.

3) Android configuration
   - Ensure the Manifest contains INTERNET permission and meta-data. We've scaffolded these in `android/app/src/main/AndroidManifest.xml`.
   - In Facebook App settings, add your Android Package Name and default Activity (`com.your.package` and `.MainActivity`), and add key hashes for debug/release.

4) iOS configuration (if you target iOS)
   - Open `ios/Runner/Info.plist` and add keys for `CFBundleURLTypes` (fb{APP_ID}), `FacebookAppID`, `FacebookClientToken`, `FacebookDisplayName`, and `LSApplicationQueriesSchemes`. See plugin docs for exact XML.
   - Set iOS minimum to 12.0 in `ios/Podfile` and Xcode project.

5) Web configuration (optional)
   - `main.dart` initializes the SDK on web using `FacebookAuth.i.webAndDesktopInitialize()` with your `AppSecrets.facebookAppId`.
   - Use HTTPS for live; localhost is allowed for testing but may show console warnings.

6) Usage
   - In the Sign In screen, tap "Continue with Facebook". On success you'll be redirected to the main screen.

Docs: https://pub.dev/packages/flutter_facebook_auth and https://facebook.meedu.app/docs/7.x.x/intro
