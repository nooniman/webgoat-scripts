# XSS Mitigation Solution Tester

Write-Host "Paste JSESSIONID:" -ForegroundColor Cyan
$sessionId = Read-Host

$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$cookie = New-Object System.Net.Cookie("JSESSIONID", $sessionId, "/", "localhost")
$webSession.Cookies.Add("http://localhost:8001", $cookie)

$url = "http://localhost:8001/WebGoat/CrossSiteScripting/attack3"

$solutions = @(
    @{
        name = "Plain request.getParameter (no encoding)"
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
                <td><%=request.getParameter("first_name")%></td>
            </tr>
            <tr>
                <td><b>Last Name:</b></td>
                <td><%=request.getParameter("last_name")%></td>
            </tr>
        </tbody>
    </table>
</body>
</html>
"@
    },
    @{
        name = "OWASP Encoder - forHtml"
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
                <td><%=org.owasp.encoder.Encode.forHtml(request.getParameter("first_name"))%></td>
            </tr>
            <tr>
                <td><b>Last Name:</b></td>
                <td>
                    <%=org.owasp.encoder.Encode.forHtml(request.getParameter("last_name"))%>
                </td>
            </tr>
        </tbody>
    </table>
</body>

</html>
"@
    },
    @{
        name = "OWASP Encoder - forHtmlContent"
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
                <td><%=org.owasp.encoder.Encode.forHtmlContent(request.getParameter("first_name"))%></td>
            </tr>
            <tr>
                <td><b>Last Name:</b></td>
                <td>
                    <%=org.owasp.encoder.Encode.forHtmlContent(request.getParameter("last_name"))%>
                </td>
            </tr>
        </tbody>
    </table>
</body>

</html>
"@
    },
    @{
        name = "JSTL c:out"
        code = @"
<html>
<head>
    <title>Using GET and POST Method to Read Form Data</title>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
</head>
<body>
    <h1>Using POST Method to Read Form Data</h1>
    <table>
        <tbody>
            <tr>
                <td><b>First Name:</b></td>
                <td><c:out value="`${param.first_name}"></c:out></td>
            </tr>
            <tr>
                <td><b>Last Name:</b></td>
                <td><c:out value="`${param.last_name}"></c:out></td>
            </tr>
        </tbody>
    </table>
</body>
</html>
"@
    },
    @{
        name = "ESAPI"
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
                <td><%=org.owasp.esapi.ESAPI.encoder().encodeForHTML(request.getParameter("first_name"))%></td>
            </tr>
            <tr>
                <td><b>Last Name:</b></td>
                <td><%=org.owasp.esapi.ESAPI.encoder().encodeForHTML(request.getParameter("last_name"))%></td>
            </tr>
        </tbody>
    </table>
</body>
</html>
"@
    },
    @{
        name = "Guava HTML Escaper"
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
                <td><%=com.google.common.html.HtmlEscapers.htmlEscaper().escape(request.getParameter("first_name"))%></td>
            </tr>
            <tr>
                <td><b>Last Name:</b></td>
                <td><%=com.google.common.html.HtmlEscapers.htmlEscaper().escape(request.getParameter("last_name"))%></td>
            </tr>
        </tbody>
    </table>
</body>
</html>
"@
    }
)

foreach ($sol in $solutions) {
    Write-Host "`nTesting: $($sol.name)" -ForegroundColor Yellow
    
    # Try different parameter names
    $params = @("editor", "editor_2", "field1", "field2", "solution")
    
    foreach ($param in $params) {
        try {
            $body = "$param=$([System.Uri]::EscapeDataString($sol.code))"
            $response = Invoke-WebRequest -Uri $url -Method POST -WebSession $webSession -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing
            
            Write-Host "  Param: $param - Response: $($response.Content.Substring(0, [Math]::Min(100, $response.Content.Length)))" -ForegroundColor Gray
            
            $json = $response.Content | ConvertFrom-Json
            
            if ($json.lessonCompleted -eq $true) {
                Write-Host "  SUCCESS!" -ForegroundColor Green
                Write-Host "  Solution: $($sol.name)" -ForegroundColor Cyan
                Write-Host "  Parameter: $param" -ForegroundColor Cyan
                Write-Host "`nCorrect code:" -ForegroundColor Green
                Write-Host $sol.code
                exit 0
            } elseif ($json.feedback -and $json.feedback -ne "This in not the correct answer. Try again!") {
                Write-Host "  Feedback: $($json.feedback)" -ForegroundColor Yellow
            }
        }
        catch {
            if ($_.Exception.Message -notmatch "404") {
                Write-Host "  Error with $param : $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

Write-Host "`nNone worked. Try checking hints in WebGoat." -ForegroundColor Yellow
