# ============================================================
# Decode and Test Admin Credentials
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Admin Credentials Decoder & Tester" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Function to decode various formats
function Decode-Credential {
    param([string]$encoded)
    
    Write-Host "Trying to decode: $encoded" -ForegroundColor Yellow
    Write-Host ""
    
    # Try Base64
    Write-Host "[1] Base64 decode:" -ForegroundColor Cyan
    try {
        $base64Decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encoded))
        Write-Host "  Result: $base64Decoded" -ForegroundColor Green
    } catch {
        Write-Host "  Not valid Base64" -ForegroundColor Red
    }
    
    # Try Hex
    Write-Host "[2] Hex decode:" -ForegroundColor Cyan
    try {
        $hexDecoded = -join ($encoded -split "(..)" | Where-Object {$_} | ForEach-Object {[char][convert]::ToInt32($_,16)})
        Write-Host "  Result: $hexDecoded" -ForegroundColor Green
    } catch {
        Write-Host "  Not valid Hex" -ForegroundColor Red
    }
    
    # Try URL decode
    Write-Host "[3] URL decode:" -ForegroundColor Cyan
    try {
        $urlDecoded = [System.Web.HttpUtility]::UrlDecode($encoded)
        Write-Host "  Result: $urlDecoded" -ForegroundColor Green
    } catch {
        Write-Host "  Not valid URL encoding" -ForegroundColor Red
    }
    
    # Try ROT13
    Write-Host "[4] ROT13 decode:" -ForegroundColor Cyan
    $rot13 = $encoded.ToCharArray() | ForEach-Object {
        if ($_ -match '[a-m]') { [char]([int]$_ + 13) }
        elseif ($_ -match '[n-z]') { [char]([int]$_ - 13) }
        elseif ($_ -match '[A-M]') { [char]([int]$_ + 13) }
        elseif ($_ -match '[N-Z]') { [char]([int]$_ - 13) }
        else { $_ }
    }
    Write-Host "  Result: $($rot13 -join '')" -ForegroundColor Green
    
    Write-Host ""
}

# Function to test credentials
function Test-AdminLogin {
    param(
        [string]$username,
        [string]$password
    )
    
    Write-Host "=====================================" -ForegroundColor Yellow
    Write-Host "Testing Login" -ForegroundColor Yellow
    Write-Host "=====================================" -ForegroundColor Yellow
    Write-Host "Username: $username" -ForegroundColor White
    Write-Host "Password: $password" -ForegroundColor White
    Write-Host ""
    
    $headers = @{
        "Content-Type" = "application/x-www-form-urlencoded"
        "Cookie" = "JSESSIONID=$sessionCookie"
    }
    
    $body = "username=$username&password=$password"
    
    # Try different login endpoints
    $endpoints = @(
        "/WebGoat/LogSecurity/login",
        "/WebGoat/login",
        "/WebGoat/LogSpoofing/login",
        "/WebGoat/PasswordReset/login"
    )
    
    foreach ($endpoint in $endpoints) {
        Write-Host "Trying endpoint: $endpoint" -ForegroundColor Gray
        
        try {
            $response = Invoke-WebRequest `
                -Uri "$webGoatUrl$endpoint" `
                -Method POST `
                -Headers $headers `
                -Body $body `
                -UseBasicParsing
            
            $result = $response.Content | ConvertFrom-Json
            
            Write-Host "  Response: $($result.feedback)" -ForegroundColor White
            
            if ($result.lessonCompleted -eq $true) {
                Write-Host ""
                Write-Host "================================================" -ForegroundColor Green
                Write-Host "SUCCESS! Logged in as admin!" -ForegroundColor Green
                Write-Host "================================================" -ForegroundColor Green
                return $true
            }
            
        } catch {
            Write-Host "  Error or 404" -ForegroundColor Red
        }
    }
    
    return $false
}

# Interactive mode
Write-Host "USAGE:" -ForegroundColor Cyan
Write-Host "1. Look at the lesson page for encoded credentials in logs" -ForegroundColor White
Write-Host "2. Copy the encoded string" -ForegroundColor White
Write-Host "3. Paste it when prompted below" -ForegroundColor White
Write-Host ""
Write-Host "Common patterns to look for:" -ForegroundColor Yellow
Write-Host "  - Base64: YWRtaW46cGFzc3dvcmQ=" -ForegroundColor Gray
Write-Host "  - Hex: 61646d696e3a70617373776f7264" -ForegroundColor Gray
Write-Host "  - Format: 'Admin password is: XXXXX'" -ForegroundColor Gray
Write-Host ""

$encodedCreds = Read-Host "Enter encoded credentials (or press Enter to skip)"

if ($encodedCreds) {
    Decode-Credential -encoded $encodedCreds
    
    Write-Host ""
    $username = Read-Host "Enter decoded username (default: admin)"
    if ([string]::IsNullOrWhiteSpace($username)) { $username = "admin" }
    
    $password = Read-Host "Enter decoded password"
    
    if ($password) {
        Test-AdminLogin -username $username -password $password
    }
} else {
    Write-Host ""
    Write-Host "No credentials provided. Manual steps:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Go to the Log Security lesson in WebGoat" -ForegroundColor White
    Write-Host "2. Look for a red log output box" -ForegroundColor White
    Write-Host "3. Find startup log messages with encoded credentials" -ForegroundColor White
    Write-Host "4. Common formats:" -ForegroundColor White
    Write-Host "   - 'Admin password: BASE64STRING'" -ForegroundColor Gray
    Write-Host "   - 'Using generated password: HEXSTRING'" -ForegroundColor Gray
    Write-Host "5. Copy the encoded part and run this script again" -ForegroundColor White
    Write-Host ""
    Write-Host "Quick decode commands:" -ForegroundColor Cyan
    Write-Host "  Base64: [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('STRING'))" -ForegroundColor Gray
    Write-Host "  Hex: -join ('STRING' -split '(..)' | ? {\$_} | % {[char][convert]::ToInt32(\$_,16)})" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "TIP: Check the lesson page!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "The logs are likely displayed directly on the lesson page" -ForegroundColor White
Write-Host "in a red box labeled 'Log output:' or 'Application logs:'" -ForegroundColor White
Write-Host ""
