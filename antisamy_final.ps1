# AntiSamy XSS Prevention - Automated Solution

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AntiSamy Stored XSS Prevention" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Paste JSESSIONID:" -ForegroundColor White
$sessionId = Read-Host

# Create web session with cookie
$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$cookie = New-Object System.Net.Cookie("JSESSIONID", $sessionId, "/", "localhost")
$webSession.Cookies.Add("http://localhost:8001", $cookie)

$url = "http://localhost:8001/WebGoat/CrossSiteScripting/attack4"

Write-Host ""
Write-Host "Testing AntiSamy solution..." -ForegroundColor Cyan
Write-Host ""

# The working solution
$solution = @"
import org.owasp.validator.html.*;
import MyCommentDAO;

public class AntiSamyController {
    public void saveNewComment(int threadID, int userID, String newComment){
        Policy policy = Policy.getInstance("antisamy-slashdot.xml");
        AntiSamy antiSamy = new AntiSamy();
        CleanResults cleanResults = antiSamy.scan(newComment, policy);
        MyCommentDAO.addComment(threadID, userID, cleanResults.getCleanHTML());
    }
}
"@

try {
    $body = @{
        editor2 = $solution
    }
    
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -WebSession $webSession -ContentType "application/x-www-form-urlencoded"
    
    if ($response.lessonCompleted -eq $true) {
        Write-Host "SUCCESS!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Lesson completed!" -ForegroundColor Green
        Write-Host "Feedback: $($response.feedback)" -ForegroundColor White
        Write-Host ""
        Write-Host "Working solution:" -ForegroundColor Cyan
        Write-Host $solution -ForegroundColor White
    } else {
        Write-Host "Failed: $($response.feedback)" -ForegroundColor Red
        Write-Host ""
        Write-Host "The solution might have changed. Check WebGoat for updates." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "  1. WebGoat is running on localhost:8001" -ForegroundColor White
    Write-Host "  2. Your session ID is valid" -ForegroundColor White
    Write-Host "  3. You're on the correct lesson page" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
