Write-Host "Paste JSESSIONID:"; $s = Read-Host; $body = @"
&lt;html&gt;

&lt;head&gt;
    &lt;title&gt;Using GET and POST Method to Read Form Data&lt;/title&gt;
&lt;/head&gt;

&lt;body&gt;
    &lt;h1&gt;Using POST Method to Read Form Data&lt;/h1&gt;
    &lt;table&gt;
        &lt;tbody&gt;
            &lt;tr&gt;
                &lt;td&gt;&lt;b&gt;First Name:&lt;/b&gt;&lt;/td&gt;
                &lt;td&gt;&lt;%=org.owasp.encoder.Encode.forHtml(request.getParameter(&quot;first_name&quot;))%&gt;&lt;/td&gt;
            &lt;/tr&gt;
            &lt;tr&gt;
                &lt;td&gt;&lt;b&gt;Last Name:&lt;/b&gt;&lt;/td&gt;
                &lt;td&gt;
                    &lt;%=org.owasp.encoder.Encode.forHtml(request.getParameter(&quot;last_name&quot;))%&gt;
                &lt;/td&gt;
            &lt;/tr&gt;
        &lt;/tbody&gt;
    &lt;/table&gt;
&lt;/body&gt;

&lt;/html&gt;
"@; curl.exe -s -X POST "http://localhost:8001/WebGoat/CrossSiteScripting/attack5b" -H "Cookie: JSESSIONID=$s" -H "Content-Type: application/x-www-form-urlencoded" --data-urlencode "editor_2=$body" | ConvertFrom-Json | Select-Object lessonCompleted,feedback