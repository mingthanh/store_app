# Payment Integration Guide

## Overview

This application uses **VietQR QuickLink** for QR code generation and **Casso/PayOS** for automatic payment detection via webhook.

## Architecture

```
User → Checkout → QR Display → Bank Transfer → Casso/PayOS → Webhook → Server → Payment Detected → Order Created
```

## Setup Instructions

### 1. Environment Configuration

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

Required settings:
- `VIETQR_BANK_BIN`: Your bank's BIN code (e.g., 970422 for MB Bank)
- `VIETQR_ACC_NUMBER`: Your account number
- `VIETQR_ACC_NAME`: Account holder name
- `QR_WEBHOOK_SECRET`: API Key from Casso/PayOS
- `MOCK_QR_WEBHOOK`: Set to `false` for production, `true` for testing

### 2. Casso/PayOS Setup

1. Register at [Casso.vn](https://casso.vn) or [PayOS.vn](https://payos.vn)
2. Connect your bank account
3. Configure webhook URL: `https://your-domain.com/api/payments/qr/webhook`
4. Copy API Key to `.env` as `QR_WEBHOOK_SECRET`

### 3. Development Mode (Mock Webhook)

For testing without real bank transfers:

```bash
# Set in .env
MOCK_QR_WEBHOOK=true

# Run mock webhook script
cd server
.\mock_casso_webhook.ps1 -OrderId "qr-123456789" -Amount 50000
```

### 4. Production Deployment

**Using ngrok (development):**
```bash
ngrok http 3000
# Use ngrok URL as webhook URL in Casso/PayOS
```

**Using production server:**
- Deploy to VPS or cloud provider
- Use HTTPS (required by Casso/PayOS)
- Update webhook URL in Casso/PayOS dashboard
- Set `MOCK_QR_WEBHOOK=false`
- Set `DEBUG=false` for less verbose logging

## Payment Flow

### 1. Create Payment Intent
```
POST /api/payments/qr/create
{
  "orderId": "qr-1234567890",
  "amountVnd": 50000
}
```

Response includes:
- Base64 QR code image
- Payment intent details
- Expiration time (15 minutes)

### 2. Display QR Code
Flutter app displays QR and polls status every 2 seconds.

### 3. User Transfers Money
User scans QR or manually transfers to account with exact:
- Amount: Must match exactly
- Content: `ORDER-qr-1234567890`

### 4. Webhook Notification
Casso/PayOS detects transaction and sends webhook to server.

### 5. Payment Matching
Server matches transaction by:
- Amount (must be exact)
- Description (must contain order ID)

### 6. Order Creation
App detects payment → Creates order → Clears cart → Shows success

## Testing

### Manual Testing with Mock Webhook

1. Start server: `node src/index.js`
2. Open app and checkout
3. Note the OrderId from QR screen
4. Run mock script:
   ```bash
   .\mock_casso_webhook.ps1 -OrderId "qr-xxx" -Amount 2000
   ```
5. App should detect payment within 2 seconds

### Real Payment Testing

1. Ensure Casso/PayOS is configured
2. Set `MOCK_QR_WEBHOOK=false`
3. Checkout in app
4. Transfer money to displayed account
5. Wait for Casso to sync (5-10 minutes)
6. Webhook triggers automatically
7. Order created automatically

## Troubleshooting

### Webhook Not Received

**Check:**
- Webhook URL is correct in Casso/PayOS
- Server is accessible (use ngrok for local testing)
- `QR_WEBHOOK_SECRET` matches Casso/PayOS API Key
- Bank account is connected in Casso/PayOS

**Debug:**
- Check server logs for webhook requests
- Verify Casso/PayOS transaction list
- Test webhook with mock script first

### Payment Not Matching

**Common Issues:**
- Amount doesn't match exactly
- Description doesn't contain correct OrderId
- QR code expired (15 min TTL)
- Case sensitivity in description

**Solution:**
- Ensure exact amount transfer
- Copy payment content exactly: `ORDER-qr-xxx`
- Create new QR if expired

### App Not Detecting Payment

**Check:**
- App is polling (check console logs)
- Server responded with `status: paid`
- Network connectivity (emulator uses 10.0.2.2)

## API Endpoints

### Create Payment
`POST /api/payments/qr/create`

### Check Status
`GET /api/payments/qr/status?orderId=qr-xxx`

### Webhook (Casso/PayOS)
`POST /api/payments/qr/webhook`

### Webhook Verification (GET)
`GET /api/payments/qr/webhook`

### Mock Payment (Dev Only)
`POST /api/payments/qr/mockPaid`

## Security Considerations

- Keep `QR_WEBHOOK_SECRET` confidential
- Use HTTPS in production
- Validate webhook signatures (currently disabled)
- Implement rate limiting on webhook endpoint
- Set proper CORS configuration

## Future Improvements

- [ ] Migrate payment intents from memory to MongoDB with TTL
- [ ] Add webhook signature verification
- [ ] Implement retry mechanism for failed webhooks
- [ ] Add payment transaction logging
- [ ] Support multiple bank accounts
- [ ] Real-time currency conversion API
- [ ] Payment analytics dashboard

## Support

For issues or questions:
- Check server logs
- Review Casso/PayOS documentation
- Test with mock webhook first
