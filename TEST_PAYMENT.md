# Hướng dẫn Test Thanh Toán Thật

## 📱 Bước 1: Tạo đơn và lấy QR

1. Đăng nhập app với tài khoản: `user@example.com` / `user123`
2. Thêm sản phẩm vào giỏ hàng
3. Nhấn "Proceed to Checkout"
4. Màn hình QR sẽ hiển thị:
   - Số tiền VND
   - QR code
   - Nội dung chuyển khoản: `ORDER-qr-1730556789123` (ví dụ)

**Lưu lại orderId này!** (phần sau "ORDER-")

## 💰 Bước 2: Chuyển khoản thật

Mở app ngân hàng của bạn:

### Thông tin tài khoản nhận:
- **Ngân hàng**: MB Bank (BIN: 970422)
- **Số tài khoản**: 0393759985
- **Tên**: Tran Thi Kim Thanh CEO BigTech VN

### Thông tin chuyển khoản:
- **Số tiền**: Đúng số tiền hiển thị trên QR (VD: 49000 VND)
- **Nội dung**: `ORDER-qr-1730556789123` (PHẢI ĐÚNG orderId từ QR screen)

⚠️ **QUAN TRỌNG**: 
- Nội dung chuyển khoản PHẢI có format: `ORDER-qr-<timestamp>`
- Số tiền PHẢI khớp chính xác
- Không có dấu, chữ thường/hoa đều được

## 🔄 Bước 3: Đánh dấu thanh toán (vì chưa có webhook thật)

Vì server đang chạy local (không có URL public), ngân hàng không thể gửi webhook tới. Sau khi chuyển khoản thật, bạn cần gọi API để đánh dấu:

### PowerShell:
```powershell
$orderId = "qr-1730556789123"  # Thay bằng orderId thật từ QR
$body = @{
    orderId = $orderId
    txId = "REAL-$(Get-Date -Format 'yyyyMMddHHmmss')"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/payments/qr/mockPaid" `
  -Method POST `
  -Body $body `
  -ContentType "application/json"
```

### Curl:
```bash
curl -X POST http://localhost:3000/api/payments/qr/mockPaid \
  -H "Content-Type: application/json" \
  -d '{"orderId":"qr-1730556789123","txId":"REAL-20251102140530"}'
```

## ✅ Bước 4: Verify

1. App sẽ tự động phát hiện status = 'paid' (do polling mỗi 2 giây)
2. Hiển thị snackbar xanh "✅ Thanh toán thành công"
3. Tự động tạo đơn hàng
4. Dialog "Đặt hàng thành công!"
5. Giỏ hàng được xóa

### Kiểm tra đơn hàng:
1. Vào tab **Account**
2. Nhấn **My Orders**
3. Xem đơn hàng vừa tạo với status `processing`

---

## 🌐 Cách 2: Setup Webhook Thật (Nâng cao)

Để webhook tự động hoạt động khi chuyển khoản, bạn cần:

### 1. Expose server ra internet
```bash
# Sử dụng ngrok (free)
ngrok http 3000

# Hoặc localtunnel
npx localtunnel --port 3000
```

Bạn sẽ nhận được URL public như: `https://abc123.ngrok-free.app`

### 2. Đăng ký webhook với dịch vụ banking aggregator

Một số dịch vụ cung cấp webhook cho giao dịch ngân hàng:
- **Casso.vn**: Hỗ trợ webhook tự động khi có giao dịch
- **VietQR.net**: Có API webhook
- **VNPay**: Có callback URL

Ví dụ với Casso:
1. Đăng ký tài khoản tại casso.vn
2. Kết nối tài khoản ngân hàng
3. Cấu hình webhook URL: `https://abc123.ngrok-free.app/api/payments/qr/webhook`
4. Set `QR_WEBHOOK_SECRET` trong `.env`
5. Bật tính năng webhook trong Casso

### 3. Update .env
```properties
MOCK_QR_WEBHOOK=false
QR_WEBHOOK_SECRET=your_secret_from_casso
```

Khi đó, mỗi lần có giao dịch, Casso sẽ tự động POST webhook tới server của bạn.

---

## 🧪 Test Nhanh (Không cần chuyển khoản thật)

Nếu chỉ muốn test flow, dùng mockPaid trực tiếp:

```powershell
# Lấy orderId từ QR screen
$orderId = "qr-1730556789123"

# Gọi mockPaid
curl -X POST http://localhost:3000/api/payments/qr/mockPaid `
  -H "Content-Type: application/json" `
  -d "{\"orderId\":\"$orderId\"}"
```

App sẽ nhận được kết quả giống như khi webhook thật được gọi.
