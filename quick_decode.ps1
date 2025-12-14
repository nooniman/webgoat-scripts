# ============================================================
# Quick Credential Decoder - Copy/Paste Mode
# ============================================================

Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           QUICK CREDENTIAL DECODER                           ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Read the encoded string
Write-Host "Paste the encoded string from the log (then press Enter):" -ForegroundColor Yellow
$encoded = Read-Host

if ([string]::IsNullOrWhiteSpace($encoded)) {
    Write-Host "No input provided. Exiting." -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Decoding: $encoded" -ForegroundColor White
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Method 1: Base64
Write-Host "[1] BASE64 DECODE:" -ForegroundColor Yellow
try {
    $base64Result = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encoded))
    Write-Host "    ✓ Success: " -ForegroundColor Green -NoNewline
    Write-Host $base64Result -ForegroundColor White
    
    # Check if it contains username:password format
    if ($base64Result -match "^(.+):(.+)$") {
        Write-Host "    → Username: " -ForegroundColor Cyan -NoNewline
        Write-Host $Matches[1] -ForegroundColor White
        Write-Host "    → Password: " -ForegroundColor Cyan -NoNewline
        Write-Host $Matches[2] -ForegroundColor White
    }
} catch {
    Write-Host "    ✗ Not valid Base64" -ForegroundColor Red
}
Write-Host ""

# Method 2: Hex
Write-Host "[2] HEX DECODE:" -ForegroundColor Yellow
try {
    # Remove any spaces or special chars
    $cleanHex = $encoded -replace '[^0-9a-fA-F]',''
    
    if ($cleanHex.Length % 2 -eq 0 -and $cleanHex -match '^[0-9a-fA-F]+$') {
        $hexResult = -join ($cleanHex -split "(..)" | Where-Object {$_} | ForEach-Object {
            [char][convert]::ToInt32($_,16)
        })
        Write-Host "    ✓ Success: " -ForegroundColor Green -NoNewline
        Write-Host $hexResult -ForegroundColor White
        
        # Check if it contains username:password format
        if ($hexResult -match "^(.+):(.+)$") {
            Write-Host "    → Username: " -ForegroundColor Cyan -NoNewline
            Write-Host $Matches[1] -ForegroundColor White
            Write-Host "    → Password: " -ForegroundColor Cyan -NoNewline
            Write-Host $Matches[2] -ForegroundColor White
        }
    } else {
        Write-Host "    ✗ Not valid Hex" -ForegroundColor Red
    }
} catch {
    Write-Host "    ✗ Hex decode failed" -ForegroundColor Red
}
Write-Host ""

# Method 3: URL Decode
Write-Host "[3] URL DECODE:" -ForegroundColor Yellow
try {
    Add-Type -AssemblyName System.Web
    $urlResult = [System.Web.HttpUtility]::UrlDecode($encoded)
    if ($urlResult -ne $encoded) {
        Write-Host "    ✓ Success: " -ForegroundColor Green -NoNewline
        Write-Host $urlResult -ForegroundColor White
    } else {
        Write-Host "    - No URL encoding detected" -ForegroundColor Gray
    }
} catch {
    Write-Host "    ✗ URL decode failed" -ForegroundColor Red
}
Write-Host ""

# Method 4: ROT13
Write-Host "[4] ROT13 DECODE:" -ForegroundColor Yellow
$rot13Result = -join ($encoded.ToCharArray() | ForEach-Object {
    if ($_ -match '[a-m]') { [char]([int]$_ + 13) }
    elseif ($_ -match '[n-z]') { [char]([int]$_ - 13) }
    elseif ($_ -match '[A-M]') { [char]([int]$_ + 13) }
    elseif ($_ -match '[N-Z]') { [char]([int]$_ - 13) }
    else { $_ }
})
Write-Host "    Result: " -ForegroundColor Green -NoNewline
Write-Host $rot13Result -ForegroundColor White
Write-Host ""

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Prompt for testing
Write-Host "Would you like to test these credentials? (y/n)" -ForegroundColor Yellow
$test = Read-Host

if ($test -eq 'y' -or $test -eq 'yes') {
    Write-Host ""
    $username = Read-Host "Enter username (default: admin)"
    if ([string]::IsNullOrWhiteSpace($username)) { $username = "admin" }
    
    $password = Read-Host "Enter password"
    
    if ($password) {
        Write-Host ""
        Write-Host "Testing credentials..." -ForegroundColor Yellow
        
        $webGoatUrl = "http://192.168.254.112:8001"
        $sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"
        
        $headers = @{
            "Content-Type" = "application/x-www-form-urlencoded"
            "Cookie" = "JSESSIONID=$sessionCookie"
        }
        
        $body = "username=$username&password=$password"
        
        try {
            $response = Invoke-WebRequest `
                -Uri "$webGoatUrl/WebGoat/LogSecurity/login" `
                -Method POST `
                -Headers $headers `
                -Body $body `
                -UseBasicParsing
            
            $result = $response.Content | ConvertFrom-Json
            
            Write-Host ""
            if ($result.lessonCompleted -eq $true) {
                Write-Host "╔═══════════════════════════════════════════════╗" -ForegroundColor Green
                Write-Host "║            ✓ SUCCESS!                         ║" -ForegroundColor Green
                Write-Host "║     Login successful! Challenge complete!    ║" -ForegroundColor Green
                Write-Host "╚═══════════════════════════════════════════════╝" -ForegroundColor Green
            } else {
                Write-Host "Response: $($result.feedback)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "Login attempt failed. Try different endpoint or check credentials." -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Cyan
