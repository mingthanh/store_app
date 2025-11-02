# Store App (Flutter + Node/Express + MongoDB)

Ứng dụng mua sắm giày dép, client Flutter (GetX) kết nối API Node/Express (MongoDB). Admin quản trị sản phẩm/đơn hàng/người dùng; người dùng duyệt sản phẩm, giỏ hàng, đặt hàng, xem đơn và chỉnh sửa hồ sơ (kèm đổi avatar).

## 1) Kiến trúc
- Client: Flutter 3.19+ (Dart 3.9+), GetX, http, file_picker.
- Server: Node 20+, Express + Mongoose + JWT; upload ảnh với Multer, phục vụ tĩnh `/uploads`.
- Auth: JWT (role 0=admin, 1=user).

## 2) Chuẩn bị
- Cài Flutter SDK, Node.js, MongoDB, Android Studio cho emulator (nếu chạy Android).

## 3) Chạy server API
```powershell
# Cài dependency (lần đầu)
pwsh -NoProfile -Command "Set-Location -LiteralPath 'D:\\WorkSpace\\LT_Mobile\\store_app\\server'; npm install"

# (Tuỳ chọn) Tạo .env tại folder server
# PORT=3000
# MONGO_URI=mongodb://127.0.0.1:27017/store_app
# MONGO_DB=store_app
# JWT_SECRET=dev_secret

# Chạy server
pwsh -NoProfile -Command "Set-Location -LiteralPath 'D:\\WorkSpace\\LT_Mobile\\store_app\\server'; npm start"
```
Mặc định chạy ở `http://localhost:3000` và phục vụ ảnh tại `http://localhost:3000/uploads/...`.

## 4) Chạy app Flutter
```powershell
flutter pub get
flutter run
```
Base URL tự động:
- Web/Desktop/iOS simulator: `http://localhost:3000`
- Android emulator: `http://10.0.2.2:3000`
Có thể override:
```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
```

## 5) Tính năng
- Admin Dashboard: Products / Orders / Users, upload ảnh hoặc nhập URL ảnh, đổi trạng thái đơn, chỉnh vai trò user.
- User: Duyệt sản phẩm (API), filter theo danh mục ở Shopping, wishlist, giỏ hàng, đặt hàng, xem đơn của tôi.
- Hồ sơ: cập nhật tên/điện thoại, đổi avatar từ gallery (upload) hoặc dán URL trực tiếp.

### Thanh toán (VietQR QuickLink)
- Ứng dụng sử dụng VietQR QuickLink (ảnh PNG lấy từ vietqr.io) để hiển thị mã QR chuyển khoản.
- Server cung cấp các API:
  - POST `/api/payments/qr/create` → tạo QR cho `orderId`, `amountVnd` và trả về `qrBase64` (PNG base64) + `addInfo`.
  - GET `/api/payments/qr/status?orderId=...` → kiểm tra trạng thái thanh toán (`pending|paid|expired`).
  - POST `/api/payments/qr/webhook` → webhook từ bên trung gian; dev có thể bật mock qua `MOCK_QR_WEBHOOK=true`.
- Environment (server/.env):
  - `VIETQR_BANK_BIN` – BIN ngân hàng (VD: 970418 cho VietinBank).
  - `VIETQR_ACC_NUMBER` – Số tài khoản nhận.
  - `VIETQR_ACC_NAME` – Tên chủ tài khoản (tùy chọn, nên đặt không dấu).
  - `VIETQR_USE_VIETQR_IO=true` – Mặc định dùng QuickLink của vietqr.io.
  - `VIETQR_TEMPLATE=compact2` – Template ảnh (compact2, img, ...).
  - `QR_WEBHOOK_SECRET` – Secret để xác thực chữ ký HMAC (nếu kết nối webhook thật).
  - `MOCK_QR_WEBHOOK=false` – Bật mock webhook khi dev.

Lưu ý: VNPay đã được gỡ bỏ hoàn toàn.

## 6) Upload ảnh
- `POST /api/uploads/images` (admin only, multipart field `image`), phản hồi `{ url: "/uploads/images/<file>" }`.
- Client ghép `ApiService.baseUrl` khi server trả relative URL.

## 7) Những file quan trọng
- `lib/services/api_service.dart` – HTTP client, tự chọn baseUrl theo platform (có chú thích tiếng Việt).
- `lib/widgets/category_chips.dart` – Chip danh mục, hỗ trợ controlled (cha điều khiển) hoặc tự quản lý.
- `lib/view/shopping_screen.dart` – Sử dụng `ProductGrid(useApi: true)` và filter category theo chips.
- `lib/widgets/product_grid.dart` – Lưới sản phẩm từ API (Image.network với fallback).
- `lib/view/admin_dashboard_api_screen.dart` – Dashboard; dialog thêm/sửa có nút Upload (file_picker + UploadRepository).
- `lib/features/my_orders/edit_profile/views/widgets/profile_image.dart` – Đổi avatar (gallery upload hoặc dán URL).
- `lib/repositories/*` – Gọi API: sản phẩm, đơn hàng, người dùng, upload.
- `server/src/index.js` – Khởi động server, mount routes, phục vụ tĩnh `/uploads`.
- `server/src/routes/uploads.js` – Route upload ảnh (admin only).

## 8) Sự cố thường gặp
- Android báo `Requested internal only, but not enough space` khi cài APK:
  - Device Manager > Wipe Data hoặc tăng Internal Storage; hoặc `adb uninstall com.example.store_app` và dọn `/data/local/tmp`.
- Android không gọi được `localhost` của host:
  - Đã dùng `10.0.2.2` tự động. Nếu vẫn lỗi, kiểm tra firewall/port.

## 9) Facebook Login (tuỳ chọn)
Ứng dụng còn phần tích hợp Facebook Login (plugin `flutter_facebook_auth`). Nếu dùng, cấu hình App ID/Client Token theo tài liệu plugin.
