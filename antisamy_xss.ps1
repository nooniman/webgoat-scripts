# Stored XSS - AntiSamy Prevention

Write-Host "Paste JSESSIONID:" -ForegroundColor Cyan
$sessionId = Read-Host

$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$cookie = New-Object System.Net.Cookie("JSESSIONID", $sessionId, "/", "localhost")
$webSession.Cookies.Add("http://localhost:8001", $cookie)

$url = "http://localhost:8001/WebGoat/CrossSiteScripting/attack4"

# Solutions using AntiSamy with antisamy-slashdot.xml policy
$solutions = @(
    @{
        name = "AntiSamy with policy file - Version 1"
        code = @"
import org.owasp.validator.html.*;
import MyCommentDAO;

public class AntiSamyController {
    ...
    public void saveNewComment(int threadID, int userID, String newComment){
        Policy policy = Policy.getInstance(this.getClass().getResourceAsStream("/antisamy-slashdot.xml"));
        AntiSamy antiSamy = new AntiSamy();
        CleanResults cleanResults = antiSamy.scan(newComment, policy);
        MyCommentDAO.addComment(threadID, userID, cleanResults.getCleanHTML());
    }
    ...
}
"@
    },
    @{
        name = "AntiSamy with policy file - Version 2 (try-catch)"
        code = @"
import org.owasp.validator.html.*;
import MyCommentDAO;

public class AntiSamyController {
    ...
    public void saveNewComment(int threadID, int userID, String newComment){
        try {
            Policy policy = Policy.getInstance(this.getClass().getResourceAsStream("/antisamy-slashdot.xml"));
            AntiSamy antiSamy = new AntiSamy();
            CleanResults cleanResults = antiSamy.scan(newComment, policy);
            MyCommentDAO.addComment(threadID, userID, cleanResults.getCleanHTML());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    ...
}
"@
    },
    @{
        name = "AntiSamy - Compact version"
        code = @"
import org.owasp.validator.html.*;
import MyCommentDAO;

public class AntiSamyController {
    ...
    public void saveNewComment(int threadID, int userID, String newComment){
        AntiSamy antiSamy = new AntiSamy();
        CleanResults cleanResults = antiSamy.scan(newComment, Policy.getInstance(this.getClass().getResourceAsStream("/antisamy-slashdot.xml")));
        MyCommentDAO.addComment(threadID, userID, cleanResults.getCleanHTML());
    }
    ...
}
"@
    },
    @{
        name = "AntiSamy - With full path"
        code = @"
import org.owasp.validator.html.*;
import MyCommentDAO;

public class AntiSamyController {
    ...
    public void saveNewComment(int threadID, int userID, String newComment){
        Policy policy = Policy.getInstance("/antisamy-slashdot.xml");
        AntiSamy antiSamy = new AntiSamy();
        CleanResults cleanResults = antiSamy.scan(newComment, policy);
        MyCommentDAO.addComment(threadID, userID, cleanResults.getCleanHTML());
    }
    ...
}
"@
    }
)

Write-Host "Testing AntiSamy solutions..." -ForegroundColor Cyan
Write-Host ""

foreach ($solution in $solutions) {
    Write-Host "Testing: $($solution.name)" -ForegroundColor Yellow
    
    $body = @{
        editor2 = $solution.code
    }
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -WebSession $webSession -ContentType "application/x-www-form-urlencoded"
        
        if ($response.lessonCompleted -eq $true) {
            Write-Host "SUCCESS!" -ForegroundColor Green
            Write-Host "Feedback: $($response.feedback)"
            Write-Host "`nWorking solution:"
            Write-Host $solution.code
            exit 0
        } else {
            Write-Host "Failed: $($response.feedback)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nTrying different endpoints..." -ForegroundColor Cyan

# Try alternative endpoints
$endpoints = @(
    "http://localhost:8001/WebGoat/CrossSiteScripting/sanitize-content",
    "http://localhost:8001/WebGoat/CrossSiteScripting/antisamy"
)

foreach ($endpoint in $endpoints) {
    Write-Host "`nTrying endpoint: $endpoint" -ForegroundColor Cyan
    
    foreach ($solution in $solutions) {
        $body = @{
            editor = $solution.code
        }
        
        try {
            $response = Invoke-RestMethod -Uri $endpoint -Method Post -Body $body -WebSession $webSession -ContentType "application/x-www-form-urlencoded"
            
            if ($response.lessonCompleted -eq $true) {
                Write-Host "SUCCESS with endpoint $endpoint!" -ForegroundColor Green
                Write-Host "Solution: $($solution.name)"
                exit 0
            }
        } catch {
            # Silently continue to next
        }
    }
}

Write-Host "`nNone worked. Check the lesson page for the correct endpoint." -ForegroundColor Red
