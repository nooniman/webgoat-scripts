# XSS Solution - Exact Format Test

Write-Host "Paste JSESSIONID:" -ForegroundColor Cyan
$sessionId = Read-Host

$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$cookie = New-Object System.Net.Cookie("JSESSIONID", $sessionId, "/", "localhost")
$webSession.Cookies.Add("http://localhost:8001", $cookie)

$url = "http://localhost:8001/WebGoat/CrossSiteScripting/attack3"

# Exact template from the payload you showed
$template = @"
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
                <td>FIRST_NAME_CODE</td>
            </tr>
            <tr>
                <td><b>Last Name:</b></td>
                <td>LAST_NAME_CODE</td>
            </tr>
        </tbody>
    </table>
</body>
</html>


"@

$solutions = @(
    @{
        name = "OWASP Encoder forHtml"
        first = '<%=org.owasp.encoder.Encode.forHtml(request.getParameter("first_name"))%>'
        last = '<%=org.owasp.encoder.Encode.forHtml(request.getParameter("last_name"))%>'
    },
    @{
        name = "OWASP Encoder forHtmlContent"
        first = '<%=org.owasp.encoder.Encode.forHtmlContent(request.getParameter("first_name"))%>'
        last = '<%=org.owasp.encoder.Encode.forHtmlContent(request.getParameter("last_name"))%>'
    },
    @{
        name = "JSTL c:out"
        first = '<c:out value="${param.first_name}"/>'
        last = '<c:out value="${param.last_name}"/>'
    },
    @{
        name = "ESAPI"
        first = '<%=org.owasp.esapi.ESAPI.encoder().encodeForHTML(request.getParameter("first_name"))%>'
        last = '<%=org.owasp.esapi.ESAPI.encoder().encodeForHTML(request.getParameter("last_name"))%>'
    }
)

foreach ($solution in $solutions) {
    Write-Host "`nTesting: $($solution.name)" -ForegroundColor Cyan
    
    $code = $template -replace 'FIRST_NAME_CODE', $solution.first -replace 'LAST_NAME_CODE', $solution.last
    
    $body = @{
        editor = $code
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -WebSession $webSession -ContentType "application/x-www-form-urlencoded"
        
        if ($response.lessonCompleted -eq $true) {
            Write-Host "SUCCESS!" -ForegroundColor Green
            Write-Host "Working solution: $($solution.name)"
            Write-Host "`nCode:"
            Write-Host $code
            exit 0
        } else {
            Write-Host "Failed: $($response.feedback)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nAll failed. Continuing search..." -ForegroundColor Red
