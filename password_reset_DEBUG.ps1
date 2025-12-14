# ============================================================
# WebGoat Password Reset - DEBUG Script
# ============================================================
# This script helps diagnose why WebWolf isn't receiving requests
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001"
$webWolfUrl = "http://192.168.254.112:8002"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Password Reset DEBUG" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check WebWolf is accessible
Write-Host "[TEST 1] Checking WebWolf accessibility..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$webWolfUrl/requests" -UseBasicParsing -TimeoutSec 5
    Write-Host "  WebWolf is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] Cannot reach WebWolf: $_" -ForegroundColor Red
}

Write-Host ""

# Test 2: Send reset with verbose output
Write-Host "[TEST 2] Sending password reset with Host header manipulation..." -ForegroundColor Yellow
Write-Host "  Target: $webGoatUrl/WebGoat/PasswordReset/ForgotPassword/create-password-reset-link" -ForegroundColor Gray
Write-Host "  Email: tom@webgoat-cloud.org" -ForegroundColor Gray
Write-Host "  Host Header: 192.168.254.112:8002 (WebWolf)" -ForegroundColor Gray
Write-Host ""

$headers = @{
    "Host" = "192.168.254.112:8002"
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
}

$body = "email=tom@webgoat-cloud.org"

try {
    $response = Invoke-WebRequest `
        -Uri "$webGoatUrl/WebGoat/PasswordReset/ForgotPassword/create-password-reset-link" `
        -Method POST `
        -Headers $headers `
        -Body $body `
        -UseBasicParsing
    
    Write-Host "Response Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response Body:" -ForegroundColor Green
    Write-Host $response.Content -ForegroundColor White
    Write-Host ""
    
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host "Parsed Response:" -ForegroundColor Cyan
    Write-Host "  Feedback: $($result.feedback)" -ForegroundColor White
    Write-Host "  Lesson Completed: $($result.lessonCompleted)" -ForegroundColor White
    Write-Host "  Assignment: $($result.assignment)" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host "[ERROR] Request failed: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    }
}

# Test 3: Try without Host header manipulation
Write-Host "[TEST 3] Sending normal password reset (no Host manipulation)..." -ForegroundColor Yellow

$normalHeaders = @{
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
}

try {
    $response = Invoke-WebRequest `
        -Uri "$webGoatUrl/WebGoat/PasswordReset/ForgotPassword/create-password-reset-link" `
        -Method POST `
        -Headers $normalHeaders `
        -Body $body `
        -UseBasicParsing
    
    Write-Host "Response Status: $($response.StatusCode)" -ForegroundColor Green
    $result = $response.Content | ConvertFrom-Json
    Write-Host "  Feedback: $($result.feedback)" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host "[ERROR] Request failed: $_" -ForegroundColor Red
}

# Test 4: Check for different endpoints
Write-Host "[TEST 4] Looking for alternative endpoints..." -ForegroundColor Yellow
Write-Host ""

$endpoints = @(
    "/WebGoat/PasswordReset/ForgotPassword/reset-link",
    "/WebGoat/PasswordReset/reset/create-reset-link",
    "/WebGoat/PasswordReset/create-password-reset",
    "/WebGoat/PasswordReset/ForgotPassword/trigger"
)

foreach ($endpoint in $endpoints) {
    Write-Host "  Trying: $endpoint" -ForegroundColor Gray
    try {
        $response = Invoke-WebRequest `
            -Uri "$webGoatUrl$endpoint" `
            -Method POST `
            -Headers $headers `
            -Body $body `
            -UseBasicParsing `
            -ErrorAction Stop
        Write-Host "    [FOUND] Status: $($response.StatusCode)" -ForegroundColor Green
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 404) {
            Write-Host "    404 Not Found" -ForegroundColor DarkGray
        } else {
            Write-Host "    Error: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Possible Issues:" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. WebGoat may ignore custom Host headers in PowerShell" -ForegroundColor White
Write-Host "   Solution: Use Burp Suite or browser developer tools" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Tom needs to 'click' the link to trigger WebWolf capture" -ForegroundColor White
Write-Host "   Solution: Check WebGoat UI for a 'simulate click' button" -ForegroundColor Gray
Write-Host ""
Write-Host "3. The Host header might need to be set differently" -ForegroundColor White
Write-Host "   Solution: Try X-Forwarded-Host or X-Forwarded-Server headers" -ForegroundColor Gray
Write-Host ""
Write-Host "Check WebWolf again at: $webWolfUrl/requests" -ForegroundColor Cyan
Write-Host ""
