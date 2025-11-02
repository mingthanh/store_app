# Mock Casso Webhook Test Script
# Usage: .\mock_casso_webhook.ps1 -OrderId "qr-1730567890123" -Amount 50000

param(
    [Parameter(Mandatory=$true)]
    [string]$OrderId,
    
    [Parameter(Mandatory=$true)]
    [int]$Amount
)

$url = "http://localhost:3000/api/payments/qr/webhook"
$body = @{
    data = @{
        id = [int](Get-Date -UFormat %s)
        tid = "TF$(Get-Date -Format 'yyMMddHHmmss')"
        description = "ORDER-$OrderId"
        amount = $Amount
        cusum_balance = 1000000
        when = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        bank_sub_acc_id = "12345"
        subAccId = "12345"
        reference = "MB$(Get-Date -Format 'yyMMddHHmmss')123456"
        transactionDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    code = "00"
    desc = "Thành công"
} | ConvertTo-Json -Depth 10

Write-Host "Sending mock webhook to: $url" -ForegroundColor Cyan
Write-Host "OrderId: ORDER-$OrderId" -ForegroundColor Yellow
Write-Host "Amount: $Amount VND" -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
    Write-Host "✅ SUCCESS!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10 | Write-Host
} catch {
    Write-Host "❌ ERROR!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
