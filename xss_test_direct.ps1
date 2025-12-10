# Direct HTML entity test

Write-Host "Paste JSESSIONID:" -ForegroundColor Cyan
$sessionId = Read-Host

$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$cookie = New-Object System.Net.Cookie("JSESSIONID", $sessionId, "/", "localhost")
$webSession.Cookies.Add("http://localhost:8001", $cookie)

$url = "http://localhost:8001/WebGoat/CrossSiteScripting/attack3"

# Test with manually HTML-encoded content
$tests = @(
    @{
        name = "Direct HTML entities"
        code = @"
<html>
<head>
    <title>Using GET and POST Method to Read Form Data</title>
</head>
<body>
    <h1>Using POST Method to Read Form Data</h1>
    <table>
        <tbody>
            <tr>
                <td><b>First Name:</b></td>
                <td>&lt;script&gt;alert('xss')&lt;/script&gt;</td>
            </tr>
            <tr>
                <td><b>Last Name:</b></td>
                <td>&lt;img src=x onerror='alert(1)'&gt;</td>
            </tr>
        </tbody>
    </table>
</body>
</html>
"@
    },
    @{
        name = "JSP with space after equals"
        code = @"
<html>
<head>
    <title>Using GET and POST Method to Read Form Data</title>
</head>
<body>
    <h1>Using POST Method to Read Form Data</h1>
    <table>
        <tbody>
            <tr>
                <td><b>First Name:</b></td>
                <td><%= org.owasp.encoder.Encode.forHtml(request.getParameter("first_name")) %></td>
            </tr>
            <tr>
                <td><b>Last Name:</b></td>
                <td><%= org.owasp.encoder.Encode.forHtml(request.getParameter("last_name")) %></td>
            </tr>
        </tbody>
    </table>
</body>
</html>
"@
    }
)

foreach ($test in $tests) {
    Write-Host "`nTesting: $($test.name)" -ForegroundColor Cyan
    
    $body = @{
        editor = $test.code
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -WebSession $webSession -ContentType "application/x-www-form-urlencoded"
        
        if ($response.lessonCompleted -eq $true) {
            Write-Host "SUCCESS!" -ForegroundColor Green
            Write-Host "Solution: $($test.name)"
            exit 0
        } else {
            Write-Host "Failed: $($response.feedback)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
