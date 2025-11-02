# Cấu hình Webhook Casso cho Thanh Toán Tự Động

## 📋 Bước 1: Expose Server ra Internet (dùng ngrok)

### Cài đặt ngrok:
1. Tải ngrok: https://ngrok.com/download
2. Giải nén và chạy

### Chạy ngrok:
```powershell
# Terminal mới (để ngrok chạy background)
ngrok http 3000
```

Bạn sẽ nhận được output:
```
Forwarding   https://abc123-456-def.ngrok-free.app -> http://localhost:3000
```

**Lưu lại URL này**: `https://abc123-456-def.ngrok-free.app`

⚠️ **Lưu ý**: Mỗi lần chạy ngrok, URL sẽ khác nhau (trừ khi dùng tài khoản trả phí).

---

## 🔗 Bước 2: Cấu hình Webhook trong Casso

1. Đăng nhập vào [Casso.vn](https://casso.vn)
2. Vào **Cài đặt** > **Thông tin doanh nghiệp** > **Webhook**
3. Nhập **Webhook URL**:
   ```
   https://statistical-centrally-sherita.ngrok-free.dev/api/payments/qr/webhook
   https://statistical-centrally-sherita.ngrok-free.dev -> http://localhost:3000
   *(Thay `abc123-456-def` bằng URL ngrok của bạn)*

4. Chọn **Loại webhook**: `Giao dịch mới`
5. **Lưu cấu hình**

### Lấy Secure Token từ Casso:
Casso sẽ cung cấp một **Secure Token** để xác thực webhook. 

1. Trong trang webhook settings, copy **Secure Token**
2. Lưu lại để dùng ở bước 3

---

## ⚙️ Bước 3: Cập nhật Server Config

Mở file `server/.env` và sửa:

```properties
# Webhook settings
QR_WEBHOOK_SECRET=<SECURE_TOKEN_FROM_CASSO>
MOCK_QR_WEBHOOK=false
```

**Ví dụ:**
```properties
QR_WEBHOOK_SECRET=casso_abc123def456ghi789
MOCK_QR_WEBHOOK=false
```

### Khởi động lại server:
```powershell
# Tắt server cũ (Ctrl+C)
# Chạy lại
cd d:\WorkSpace\LT_Mobile\store_app\server
node src/index.js
```

---

## 🧪 Bước 4: Test Webhook

### Test trong Casso:
1. Vào trang Webhook settings trong Casso
2. Nhấn nút **"Test Webhook"**
3. Casso sẽ gửi một webhook test tới server của bạn
4. Kiểm tra console server xem có log `[Webhook] Received` không

### Test với giao dịch thật:

#### 1. Tạo đơn hàng trong app:
- Đăng nhập app
- Thêm sản phẩm vào cart
- Checkout → Hiển thị QR
- **Lưu lại orderId** (VD: `qr-1730567890123`)

#### 2. Chuyển khoản:
```
Ngân hàng: MB Bank (970422)
Số TK: 0393759985
Số tiền: [Số tiền từ QR]
Nội dung: ORDER-qr-1730567890123
```

#### 3. Quan sát:
- **Casso**: Sẽ hiện giao dịch mới
- **Server console**: Sẽ log `[Webhook] Received` và `[Webhook] ✅ Matched`
- **App**: Tự động phát hiện paid → tạo đơn → xóa cart

---

## 📊 Webhook Format từ Casso

Server đã được cập nhật để hỗ trợ format của Casso:

```json
{
  "id": 123456,
  "tid": "FT21123456789",
  "amount": 49000,
  "description": "ORDER-qr-1730567890123",
  "when": "2025-11-02 14:30:00"
}
```

Server tự động map:
- `id` hoặc `tid` → `txId`
- `amount` → amount
- `description` → description
- `when` → timestamp

---

## 🔍 Troubleshooting

### Webhook không nhận được:

1. **Kiểm tra ngrok đang chạy:**
   ```powershell
   # Trong terminal ngrok, phải thấy:
   # Forwarding   https://...ngrok-free.app -> http://localhost:3000
   ```

2. **Kiểm tra server đang chạy:**
   ```powershell
   curl http://localhost:3000/health
   # Phải trả về: {"ok":true,"dbState":1}
   ```

3. **Test webhook URL:**
   ```powershell
   curl -X POST https://abc123-456-def.ngrok-free.app/api/payments/qr/webhook `
     -H "Content-Type: application/json" `
     -d '{"amount":49000,"description":"ORDER-qr-test","tid":"TEST123"}'
   ```

4. **Xem log server:**
   Server sẽ in ra console:
   ```
   [Webhook] Received: txId=TEST123, amount=49000, desc="ORDER-qr-test"
   [Webhook] ⚠️ No match found (nếu không có orderId pending)
   ```

### Webhook nhận được nhưng không match:

- **Kiểm tra số tiền**: Phải khớp chính xác (VD: 49000)
- **Kiểm tra nội dung**: Phải có `ORDER-qr-<orderId>`
- **Kiểm tra TTL**: QR chỉ valid 15 phút
- **Xem log**: Server sẽ log lý do không match

---

## 🚀 Production Setup (Nâng cao)

Thay vì ngrok (URL thay đổi), dùng domain cố định:

### Option 1: Deploy server lên VPS
- Deploy server lên VPS (DigitalOcean, AWS, etc.)
- Có domain cố định: `https://api.yourstore.com`
- Webhook URL: `https://api.yourstore.com/api/payments/qr/webhook`

### Option 2: Cloudflare Tunnel
- Free và có domain cố định
- Xem: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/

### Option 3: Ngrok paid plan
- $8/month
- Domain cố định
- Không cần update webhook URL mỗi lần restart

---

## ✅ Checklist Setup Hoàn Chỉnh

- [ ] Cài đặt và chạy ngrok
- [ ] Copy ngrok URL (https://...)
- [ ] Cấu hình webhook trong Casso với URL ngrok
- [ ] Copy Secure Token từ Casso
- [ ] Update `QR_WEBHOOK_SECRET` trong `.env`
- [ ] Set `MOCK_QR_WEBHOOK=false` trong `.env`
- [ ] Khởi động lại server
- [ ] Test webhook trong Casso
- [ ] Test với giao dịch thật

**Sau khi hoàn thành, hệ thống sẽ tự động nhận webhook khi có giao dịch!** 🎉
