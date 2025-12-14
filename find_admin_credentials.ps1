# ============================================================
# Search for Admin Credentials in Logs
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001"
$webWolfUrl = "http://192.168.254.112:8002"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Searching for Admin Credentials" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$headers = @{
    "Cookie" = "JSESSIONID=$sessionCookie"
}

# Common log file paths to try
$logPaths = @(
    "/WebGoat/logs",
    "/WebGoat/app.log",
    "/WebGoat/application.log",
    "/WebGoat/server.log",
    "/WebGoat/boot.log",
    "/WebGoat/startup.log",
    "/WebGoat/debug.log",
    "/logs",
    "/logs/webgoat.log",
    "/logs/application.log",
    "/admin/logs",
    "/actuator/logfile"  # Spring Boot actuator endpoint
)

Write-Host "[STEP 1] Trying common log endpoints..." -ForegroundColor Yellow
Write-Host ""

foreach ($path in $logPaths) {
    Write-Host "  Checking: $webGoatUrl$path" -ForegroundColor Gray -NoNewline
    
    try {
        $response = Invoke-WebRequest `
            -Uri "$webGoatUrl$path" `
            -Method GET `
            -Headers $headers `
            -UseBasicParsing `
            -TimeoutSec 5 `
            -ErrorAction Stop
        
        Write-Host " [FOUND!]" -ForegroundColor Green
        Write-Host ""
        Write-Host "Response (first 500 chars):" -ForegroundColor Cyan
        Write-Host $response.Content.Substring(0, [Math]::Min(500, $response.Content.Length)) -ForegroundColor White
        Write-Host ""
        Write-Host "Searching for credentials patterns..." -ForegroundColor Yellow
        
        # Look for common credential patterns
        if ($response.Content -match "admin.*password|password.*admin|credentials|secret") {
            Write-Host "[FOUND CREDENTIAL KEYWORDS]" -ForegroundColor Green
            Write-Host $Matches[0] -ForegroundColor White
        }
        
        # Look for base64-encoded strings
        $base64Pattern = "[A-Za-z0-9+/]{20,}={0,2}"
        if ($response.Content -match $base64Pattern) {
            Write-Host "[FOUND BASE64-LIKE STRING]" -ForegroundColor Cyan
            Write-Host "Encoded: $($Matches[0])" -ForegroundColor White
            
            try {
                $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Matches[0]))
                Write-Host "Decoded: $decoded" -ForegroundColor Green
            } catch {
                Write-Host "Could not decode as Base64" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 404) {
            Write-Host " 404" -ForegroundColor DarkGray
        } elseif ($_.Exception.Response.StatusCode.value__ -eq 403) {
            Write-Host " 403 Forbidden" -ForegroundColor Yellow
        } else {
            Write-Host " Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Yellow
Write-Host "[STEP 2] Checking WebWolf logs" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Yellow
Write-Host ""

$webWolfPaths = @(
    "/logs",
    "/files",
    "/requests"
)

foreach ($path in $webWolfPaths) {
    Write-Host "  Checking: $webWolfUrl$path" -ForegroundColor Gray -NoNewline
    
    try {
        $response = Invoke-WebRequest `
            -Uri "$webWolfUrl$path" `
            -Method GET `
            -UseBasicParsing `
            -TimeoutSec 5 `
            -ErrorAction Stop
        
        Write-Host " [FOUND!]" -ForegroundColor Green
        Write-Host "Response length: $($response.Content.Length) bytes" -ForegroundColor White
        Write-Host ""
        
    } catch {
        Write-Host " Not accessible" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Yellow
Write-Host "[STEP 3] Check lesson page source" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Yellow
Write-Host ""

try {
    # Get the lesson page
    $response = Invoke-WebRequest `
        -Uri "$webGoatUrl/WebGoat/start.mvc" `
        -Method GET `
        -Headers $headers `
        -UseBasicParsing
    
    Write-Host "Searching lesson page for encoded credentials..." -ForegroundColor Gray
    
    # Look for common encoding patterns in comments or hidden fields
    if ($response.Content -match "<!--.*?(admin|password|credentials|secret).*?-->") {
        Write-Host "[FOUND IN HTML COMMENT]" -ForegroundColor Green
        Write-Host $Matches[0] -ForegroundColor White
    }
    
    # Look for data attributes or hidden inputs
    if ($response.Content -match "data-.*?=`"([A-Za-z0-9+/=]{20,})`"") {
        Write-Host "[FOUND BASE64 IN DATA ATTRIBUTE]" -ForegroundColor Cyan
        Write-Host "Encoded: $($Matches[1])" -ForegroundColor White
        try {
            $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Matches[1]))
            Write-Host "Decoded: $decoded" -ForegroundColor Green
        } catch {}
    }
    
} catch {
    Write-Host "Could not access lesson page" -ForegroundColor Red
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Manual Investigation Steps" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open WebWolf in browser: $webWolfUrl" -ForegroundColor White
Write-Host "   - Check all tabs for log files" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Open WebGoat lesson in browser" -ForegroundColor White
Write-Host "   - Press F12 (Developer Tools)" -ForegroundColor Gray
Write-Host "   - Check Console for any log messages" -ForegroundColor Gray
Write-Host "   - Check Network tab for responses" -ForegroundColor Gray
Write-Host "   - View Page Source (Ctrl+U) and search for 'admin'" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Look for the red log output box on the lesson page" -ForegroundColor White
Write-Host "   - It might show startup logs" -ForegroundColor Gray
Write-Host "   - Look for encoded strings (Base64, Hex)" -ForegroundColor Gray
Write-Host ""
Write-Host "Common Base64 decoder in PowerShell:" -ForegroundColor Yellow
Write-Host '  [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("YOUR_STRING"))' -ForegroundColor Cyan
Write-Host ""
Write-Host "Common Hex decoder:" -ForegroundColor Yellow
Write-Host '  -join ($hexString -split "(..)" | ? {$_} | % {[char][convert]::ToInt32($_,16)})' -ForegroundColor Cyan
Write-Host ""
