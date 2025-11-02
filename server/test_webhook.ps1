# Test Webhook Script

# Test 1: Ping server health
Write-Host "Test 1: Checking server health..." -ForegroundColor Cyan
curl.exe http://localhost:3000/health
Write-Host ""

# Test 2: Test webhook endpoint với POST
Write-Host "Test 2: Testing webhook endpoint..." -ForegroundColor Cyan
$body = @{
    amount = 49000
    description = "ORDER-qr-test123"
    tid = "TEST123"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "https://statistical-centrally-sherita.ngrok-free.dev/api/payments/qr/webhook" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"

Write-Host "Response:" -ForegroundColor Green
$response | ConvertTo-Json
Write-Host ""

Write-Host "✅ Nếu thấy {ok: true}, webhook hoạt động tốt!" -ForegroundColor Green
Write-Host "⚠️ Nếu {matched: false}, đó là bình thường vì không có orderId pending" -ForegroundColor Yellow
