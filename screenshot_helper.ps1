# WebGoat Screenshot Helper with Timestamps
# Purpose: Capture screenshots with embedded timestamps for academic submission

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   WebGoat Screenshot Helper" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Create screenshots folder if it doesn't exist
$screenshotPath = "c:\webgoat-scripts-1\screenshots"
if (-not (Test-Path $screenshotPath)) {
    New-Item -ItemType Directory -Path $screenshotPath | Out-Null
    Write-Host "✅ Created screenshots folder: $screenshotPath`n" -ForegroundColor Green
}

# Screenshot checklist
$screenshots = @(
    @{
        Number = 1
        Name = "01_webgoat_homepage.png"
        Description = "WebGoat homepage with challenge menu visible"
        Instructions = @"
1. Open browser to http://192.168.254.112:8001/WebGoat
2. Make sure challenge menu shows 'Client Side' category
3. Press Win+Shift+S to capture
4. Select area and save
"@
    },
    @{
        Number = 2
        Name = "02_field_restrictions_interface.png"
        Description = "Field Restrictions challenge interface"
        Instructions = @"
1. Navigate to: Client Side → Field Restrictions
2. Show the form with all fields (dropdown, radio, checkbox, text inputs)
3. Make sure challenge instructions are visible
4. Press Win+Shift+S to capture
"@
    },
    @{
        Number = 3
        Name = "03_powershell_challenge1.png"
        Description = "PowerShell executing Challenge #1 script"
        Instructions = @"
1. Open PowerShell
2. Run: cd c:\webgoat-scripts-1\
3. Run: .\bypass_field_restrictions.ps1
4. Capture the terminal showing command execution
5. Press Win+Shift+S to capture
"@
    },
    @{
        Number = 4
        Name = "04_challenge1_success.png"
        Description = "Success message for Challenge #1"
        Instructions = @"
1. Show WebGoat success notification (green checkmark/banner)
   OR PowerShell output showing HTTP 200 response
2. Challenge should be marked as complete
3. Press Win+Shift+S to capture
"@
    },
    @{
        Number = 5
        Name = "05_input_validation_interface.png"
        Description = "Input Validation challenge interface"
        Instructions = @"
1. Navigate to: Client Side → Frontend Validation
2. Show all 7 form fields with validation rules visible
3. Make sure challenge instructions are displayed
4. Press Win+Shift+S to capture
"@
    },
    @{
        Number = 6
        Name = "06_powershell_challenge2.png"
        Description = "PowerShell executing Challenge #2 script"
        Instructions = @"
1. Open PowerShell
2. Run: cd c:\webgoat-scripts-1\
3. Run: .\frontend_validation_attack.ps1
4. Capture terminal showing command and output
5. Press Win+Shift+S to capture
"@
    },
    @{
        Number = 7
        Name = "07_challenge2_success.png"
        Description = "Success message for Challenge #2"
        Instructions = @"
1. Show WebGoat success message for validation bypass
2. Or show HTTP response accepting invalid values
3. Challenge completion indicator visible
4. Press Win+Shift+S to capture
"@
    },
    @{
        Number = 8
        Name = "08_progress_dashboard.png"
        Description = "WebGoat progress dashboard"
        Instructions = @"
1. Click your username in top-right corner
2. Go to User Profile or Progress page
3. Show completed challenges with scores
4. Show overall completion percentage
5. Press Win+Shift+S to capture
"@
    }
)

Write-Host "📸 SCREENSHOT CAPTURE GUIDE`n" -ForegroundColor Yellow
Write-Host "You need to capture 8 screenshots. Follow each step carefully:`n" -ForegroundColor White

$currentTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "⏰ Current timestamp: $currentTimestamp`n" -ForegroundColor Cyan

foreach ($screenshot in $screenshots) {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "📸 Screenshot $($screenshot.Number) of 8" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "File: $($screenshot.Name)" -ForegroundColor Cyan
    Write-Host "Description: $($screenshot.Description)" -ForegroundColor White
    Write-Host "`nInstructions:" -ForegroundColor Green
    Write-Host $screenshot.Instructions
    Write-Host "`nSave to: $screenshotPath\$($screenshot.Name)" -ForegroundColor Magenta
    Write-Host "`nPress any key when ready to continue to next screenshot..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host ""
}

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "   ALL SCREENSHOTS PLANNED!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Green

# Verify screenshots
Write-Host "Checking for captured screenshots..." -ForegroundColor Yellow
$capturedFiles = Get-ChildItem -Path $screenshotPath -Filter "*.png" -ErrorAction SilentlyContinue

if ($capturedFiles) {
    Write-Host "`n✅ Found $($capturedFiles.Count) screenshot(s):`n" -ForegroundColor Green
    foreach ($file in $capturedFiles) {
        $fileSize = [math]::Round($file.Length / 1KB, 2)
        Write-Host "   📷 $($file.Name) - ${fileSize}KB" -ForegroundColor Cyan
    }
    
    if ($capturedFiles.Count -lt 8) {
        Write-Host "`n⚠️  You have $($capturedFiles.Count) of 8 required screenshots." -ForegroundColor Yellow
        Write-Host "   Still needed: $(8 - $capturedFiles.Count) more screenshots`n" -ForegroundColor Yellow
    } else {
        Write-Host "`n🎉 All 8 screenshots captured! Great job!`n" -ForegroundColor Green
    }
} else {
    Write-Host "`n⚠️  No screenshots found yet." -ForegroundColor Red
    Write-Host "   Please capture screenshots using Win+Shift+S and save them to:" -ForegroundColor Yellow
    Write-Host "   $screenshotPath`n" -ForegroundColor Cyan
}

# Create timestamp overlay instructions
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "   TIMESTAMP INSTRUCTIONS" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

Write-Host "Option 1: Windows Clock Widget (Easiest)" -ForegroundColor Green
Write-Host "1. Right-click taskbar → Taskbar settings" -ForegroundColor White
Write-Host "2. Enable 'Widgets' to show date/time" -ForegroundColor White
Write-Host "3. Keep taskbar visible in screenshots`n" -ForegroundColor White

Write-Host "Option 2: PowerShell Timestamp Window" -ForegroundColor Green
Write-Host "Run this command in a separate PowerShell window:" -ForegroundColor White
Write-Host @"
while (`$true) { 
    Clear-Host
    Write-Host "TIMESTAMP: `$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green
    Start-Sleep -Seconds 1 
}
"@ -ForegroundColor Cyan
Write-Host "Keep this window visible while taking screenshots`n" -ForegroundColor White

Write-Host "Option 3: ShareX (Professional - Recommended)" -ForegroundColor Green
Write-Host "1. Download ShareX from https://getsharex.com/" -ForegroundColor White
Write-Host "2. Install and run ShareX" -ForegroundColor White
Write-Host "3. Go to: Task Settings → Capture → Screen Capture → Annotations" -ForegroundColor White
Write-Host "4. Enable 'Draw timestamp on screenshot'" -ForegroundColor White
Write-Host "5. Use ShareX to capture (Ctrl+Print Screen)`n" -ForegroundColor White

# Create reference document
$referenceDoc = @"
# WebGoat Screenshot Reference Guide
**Date:** $(Get-Date -Format 'yyyy-MM-dd')
**Timestamp:** $(Get-Date -Format 'HH:mm:ss')

## Required Screenshots (8 Total)

### Screenshot 1: WebGoat Homepage
- **Filename:** 01_webgoat_homepage.png
- **URL:** http://192.168.254.112:8001/WebGoat
- **Content:** Challenge menu with 'Client Side' category visible
- **Status:** [ ] Captured

### Screenshot 2: Field Restrictions Interface
- **Filename:** 02_field_restrictions_interface.png
- **Challenge:** Client Side → Field Restrictions
- **Content:** Form with dropdown, radio, checkbox, text inputs
- **Status:** [ ] Captured

### Screenshot 3: PowerShell Challenge #1
- **Filename:** 03_powershell_challenge1.png
- **Command:** .\bypass_field_restrictions.ps1
- **Content:** PowerShell terminal showing script execution
- **Status:** [ ] Captured

### Screenshot 4: Challenge #1 Success
- **Filename:** 04_challenge1_success.png
- **Content:** WebGoat success message or HTTP 200 response
- **Status:** [ ] Captured

### Screenshot 5: Input Validation Interface
- **Filename:** 05_input_validation_interface.png
- **Challenge:** Client Side → Frontend Validation
- **Content:** 7 form fields with validation rules visible
- **Status:** [ ] Captured

### Screenshot 6: PowerShell Challenge #2
- **Filename:** 06_powershell_challenge2.png
- **Command:** .\frontend_validation_attack.ps1
- **Content:** PowerShell terminal showing script execution
- **Status:** [ ] Captured

### Screenshot 7: Challenge #2 Success
- **Filename:** 07_challenge2_success.png
- **Content:** Success message showing validation bypass
- **Status:** [ ] Captured

### Screenshot 8: Progress Dashboard
- **Filename:** 08_progress_dashboard.png
- **Content:** User profile showing completed challenges and scores
- **Status:** [ ] Captured

## Timestamp Requirements

All screenshots must include a visible timestamp showing:
- Date: $(Get-Date -Format 'yyyy-MM-dd')
- Time: Current time when captured

Methods:
1. Keep Windows taskbar visible (shows time)
2. Run timestamp PowerShell window
3. Use ShareX with timestamp overlay

## Quality Checklist

- [ ] All 8 screenshots captured
- [ ] Timestamps visible on all screenshots
- [ ] Screenshots are clear and readable
- [ ] File names match exactly as specified
- [ ] All saved to: c:\webgoat-scripts-1\screenshots\
- [ ] File size reasonable (100KB-2MB each)
- [ ] No sensitive personal information visible (except student name)

## Common Issues

**Issue:** Screenshot too dark
**Solution:** Increase screen brightness before capturing

**Issue:** Text too small
**Solution:** Increase browser zoom (Ctrl++) before capturing

**Issue:** Timestamp not visible
**Solution:** Position timestamp window in corner of screen

**Issue:** File name wrong
**Solution:** Rename files exactly as listed above

## After Capturing

Run the organizer script:
```powershell
cd c:\webgoat-scripts-1\
.\organize_deliverables.ps1
```

This will copy all screenshots to your Google Drive upload folder.
"@

$referenceDoc | Out-File -FilePath "$screenshotPath\SCREENSHOT_REFERENCE.txt" -Encoding UTF8

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "   REFERENCE GUIDE CREATED" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Green

Write-Host "📄 Detailed reference guide saved to:" -ForegroundColor Yellow
Write-Host "   $screenshotPath\SCREENSHOT_REFERENCE.txt`n" -ForegroundColor Cyan

Write-Host "🚀 QUICK TIPS:`n" -ForegroundColor Yellow
Write-Host "   • Use Win+Shift+S for quick screenshot tool" -ForegroundColor White
Write-Host "   • Keep taskbar visible for timestamp" -ForegroundColor White
Write-Host "   • Take screenshots in order (1-8)" -ForegroundColor White
Write-Host "   • Save with exact filenames listed above" -ForegroundColor White
Write-Host "   • Review screenshots before moving to next`n" -ForegroundColor White

Write-Host "✅ Screenshot helper complete! Good luck! 📸`n" -ForegroundColor Green

# Open screenshots folder
Start-Process explorer.exe -ArgumentList $screenshotPath
