# Order By SQL Injection - IP Address Extractor

$url = "http://localhost:8001/WebGoat/SqlInjectionMitigations/servers"
$submitUrl = "http://localhost:8001/WebGoat/SqlInjectionMitigations/attack12a"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WebGoat Session ID Required" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open WebGoat in your browser (make sure you're logged in)" -ForegroundColor White
Write-Host "2. Navigate to: SQL Injection (mitigation) -> Order by" -ForegroundColor White
Write-Host "3. Press F12 to open Developer Tools" -ForegroundColor White
Write-Host "4. Go to Console tab" -ForegroundColor White
Write-Host "5. Type: document.cookie" -ForegroundColor White
Write-Host "6. Look for JSESSIONID=XXXXXXXX (copy ONLY the hex value after =)" -ForegroundColor White
Write-Host ""
Write-Host "Example: If you see 'JSESSIONID=ABC123DEF456'" -ForegroundColor Gray
Write-Host "         Copy only: ABC123DEF456" -ForegroundColor Gray
Write-Host ""
$rawInput = Read-Host "Paste JSESSIONID value here (just the hex part)"

# Clean up the input - remove quotes, JSESSIONID= prefix, etc
$webgoatSessionId = $rawInput -replace '"', '' -replace "'", '' -replace 'JSESSIONID=', '' -replace 'JSESSIONID:', '' -replace '\s', ''

if ([string]::IsNullOrWhiteSpace($webgoatSessionId)) {
    Write-Host "No session ID provided. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Using session: $webgoatSessionId" -ForegroundColor Green
Write-Host ""

# Create a proper web session with cookie
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$cookie = New-Object System.Net.Cookie("JSESSIONID", $webgoatSessionId, "/", "localhost")
$session.Cookies.Add("http://localhost:8001", $cookie)

$headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0"
    "Accept" = "*/*"
    "Accept-Language" = "en-US,en;q=0.5"
    "X-Requested-With" = "XMLHttpRequest"
    "Origin" = "http://localhost:8001"
    "Referer" = "http://localhost:8001/WebGoat/start.mvc"
}

Write-Host "Starting ORDER BY SQL Injection to find webgoat-prd IP..." -ForegroundColor Green
Write-Host "Known suffix: xxx.130.219.202" -ForegroundColor Yellow
Write-Host "Testing IPs from 1.130.219.202 to 255.130.219.202..." -ForegroundColor Cyan
Write-Host ""

$foundIP = ""

for ($octet1 = 1; $octet1 -le 255; $octet1++) {
    $testIP = "$octet1.130.219.202"
    
    Write-Host "[$octet1/255] Testing: $testIP" -ForegroundColor Gray
    
    try {
        $body = "ip=$testIP"
        
        $response = Invoke-WebRequest -Uri $submitUrl -Method POST -WebSession $session -ContentType "application/x-www-form-urlencoded; charset=UTF-8" -Body $body -UseBasicParsing -ErrorAction Stop
        
        try {
            $jsonResponse = $response.Content | ConvertFrom-Json
            
            if ($jsonResponse.lessonCompleted -eq $true) {
                $foundIP = $testIP
                Write-Host ""
                Write-Host "=== FOUND IT! ===" -ForegroundColor Green
                Write-Host "IP Address: $foundIP" -ForegroundColor Yellow
                Write-Host "Response: $($response.Content)" -ForegroundColor Cyan
                break
            }
        }
        catch {
            # Not JSON - continue
        }
    }
    catch {
        if ($_.Exception.Message -match "401") {
            Write-Host ""
            Write-Host "SESSION EXPIRED at IP $testIP!" -ForegroundColor Red
            Write-Host "Get a new session and run again." -ForegroundColor Yellow
            exit 1
        }
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

if ($foundIP) {
    Write-Host ""
    Write-Host "=== SUCCESS ===" -ForegroundColor Green
    Write-Host "webgoat-prd IP Address: $foundIP" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "IP not found in range 1-255.130.219.202" -ForegroundColor Red
}