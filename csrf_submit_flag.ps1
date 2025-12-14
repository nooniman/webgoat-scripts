# CSRF Basic GET - Submit Flag Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WebGoat CSRF - Submit Flag" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "First, get your JSESSIONID:" -ForegroundColor White
$rawInput = Read-Host "Paste JSESSIONID value"

$sessionId = $rawInput -replace '"', '' -replace "'", '' -replace 'JSESSIONID=', '' -replace 'JSESSIONID:', '' -replace '\s', ''

if ([string]::IsNullOrWhiteSpace($sessionId)) {
    Write-Host "No session ID provided. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Now enter the flag value you received:" -ForegroundColor White
$flagValue = Read-Host "Flag Value"

Write-Host ""
Write-Host "Using session: $sessionId" -ForegroundColor Green
Write-Host "Submitting flag: $flagValue" -ForegroundColor Green
Write-Host ""

# Create web session with cookie
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$cookie = New-Object System.Net.Cookie("JSESSIONID", $sessionId, "/", "192.168.254.112")
$session.Cookies.Add("http://192.168.254.112:8001", $cookie)

# Try to submit the flag
$submitUrl = "http://192.168.254.112:8001/WebGoat/csrf/confirm-flag-1"

Write-Host "=== Submitting Flag ===" -ForegroundColor Cyan
Write-Host ""

try {
    $body = @{
        confirmFlagVal = $flagValue
    }
    
    $response = Invoke-RestMethod -Uri $submitUrl -Method Post -Body $body -WebSession $session -ContentType "application/x-www-form-urlencoded"
    
    Write-Host "Response:" -ForegroundColor Cyan
    Write-Host ($response | ConvertTo-Json -Depth 10) -ForegroundColor White
    Write-Host ""
    
    if ($response.lessonCompleted -eq $true) {
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "✓ SUCCESS! Lesson Completed!" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Green
    } else {
        Write-Host "Not completed yet." -ForegroundColor Yellow
        if ($response.feedback) {
            Write-Host "Feedback: $($response.feedback)" -ForegroundColor Gray
        }
    }
    
} catch {
    Write-Host "Error submitting flag:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Note: If the endpoint is wrong, try these alternatives:" -ForegroundColor Yellow
    Write-Host "- /WebGoat/csrf/confirm-flag" -ForegroundColor Gray
    Write-Host "- /WebGoat/csrf/basic-get-flag/confirm" -ForegroundColor Gray
    Write-Host ""
    Write-Host "You can also just paste the flag directly in the WebGoat web interface." -ForegroundColor Cyan
}
