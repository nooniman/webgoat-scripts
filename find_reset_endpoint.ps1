# Find Password Reset Endpoint
# This script will help identify the correct endpoint

$webGoatBase = "http://192.168.254.112:8001"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Finding Password Reset Endpoint" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Please provide your JSESSIONID cookie:" -ForegroundColor Yellow
Write-Host "(Open browser F12 > Application > Cookies > Copy JSESSIONID value)" -ForegroundColor Gray
$sessionCookie = Read-Host "JSESSIONID"
Write-Host ""

$endpoints = @(
    "/WebGoat/PasswordReset/reset/reset-password",
    "/WebGoat/PasswordReset/reset",
    "/WebGoat/PasswordReset/ForgotPassword/reset",
    "/WebGoat/PasswordReset/forgot-password",
    "/WebGoat/PasswordReset/reset-password"
)

Write-Host "Testing endpoints..." -ForegroundColor Yellow
Write-Host ""

$headers = @{
    "Cookie" = "JSESSIONID=$sessionCookie"
    "Content-Type" = "application/x-www-form-urlencoded"
}

foreach ($endpoint in $endpoints) {
    Write-Host "Testing: $endpoint" -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri "$webGoatBase$endpoint" `
            -Method POST `
            -Headers $headers `
            -Body "email=test@test.com" `
            -UseBasicParsing `
            -ErrorAction Stop
        
        Write-Host "  [SUCCESS] Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "  This endpoint works!" -ForegroundColor Green
        Write-Host ""
        
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 405) {
            Write-Host "  [MAYBE] 405 Method Not Allowed - might be correct endpoint, wrong method" -ForegroundColor Yellow
        } elseif ($statusCode -eq 400) {
            Write-Host "  [MAYBE] 400 Bad Request - endpoint exists, check parameters" -ForegroundColor Yellow
        } elseif ($statusCode -eq 404) {
            Write-Host "  [NO] 404 Not Found" -ForegroundColor Red
        } else {
            Write-Host "  [UNKNOWN] Status: $statusCode" -ForegroundColor Gray
        }
        Write-Host ""
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Alternative: Check Network Tab" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Manual Method:" -ForegroundColor Yellow
Write-Host "1. Open WebGoat Password Reset lesson" -ForegroundColor Gray
Write-Host "2. Open DevTools (F12) > Network tab" -ForegroundColor Gray
Write-Host "3. Enter an email and click Submit" -ForegroundColor Gray
Write-Host "4. Look for the POST request in Network tab" -ForegroundColor Gray
Write-Host "5. Copy the full URL/endpoint" -ForegroundColor Gray
Write-Host ""
