# WebGoat Project - Final Verification Script
# Purpose: Check completion status of all deliverables before submission

param(
    [switch]$ShowHelp
)

if ($ShowHelp) {
    Write-Host @"
WEBGOAT PROJECT - FINAL VERIFICATION SCRIPT

This script verifies that all deliverables are ready for submission.

USAGE:
    .\verify_submission.ps1

WHAT IT CHECKS:
    ✓ Report PDF exists and has content
    ✓ Video file exists and has reasonable size
    ✓ All 8 screenshots captured
    ✓ Progress JSON exists
    ✓ Attack scripts present
    ✓ Google Drive folder structure ready
    ✓ Overall readiness score

OUTPUT:
    - Detailed status of each deliverable
    - Missing items highlighted in red
    - Readiness percentage
    - Next steps recommendations
"@
    exit
}

# Color functions
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Cyan }
function Write-Section { param($Message) Write-Host "`n━━━━ $Message ━━━━" -ForegroundColor Magenta }

# Header
Clear-Host
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║    WebGoat Project - Final Verification Script         ║" -ForegroundColor Cyan
Write-Host "║    Course: IT 143 - Information Assurance Security 2   ║" -ForegroundColor Cyan
Write-Host "║    Chapter: 4 - Information & Cryptography             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "Running comprehensive verification checks...`n" -ForegroundColor Yellow

# Initialize scoring
$totalChecks = 0
$passedChecks = 0
$issues = @()

# Check 1: WebGoat Challenges Completed
Write-Section "WebGoat Challenges Status"
$totalChecks += 2

$script1 = "c:\webgoat-scripts-1\bypass_field_restrictions.ps1"
$script2 = "c:\webgoat-scripts-1\frontend_validation_attack.ps1"

if (Test-Path $script1) {
    Write-Success "Challenge #1: Field Restrictions Bypass script present"
    $passedChecks++
} else {
    Write-Error "Challenge #1 script missing: $script1"
    $issues += "Missing: bypass_field_restrictions.ps1"
}

if (Test-Path $script2) {
    Write-Success "Challenge #2: Input Validation Bypass script present"
    $passedChecks++
} else {
    Write-Error "Challenge #2 script missing: $script2"
    $issues += "Missing: frontend_validation_attack.ps1"
}

# Check 2: Report Status
Write-Section "Report Status"
$totalChecks += 3

$reportMd = "c:\webgoat-scripts-1\WEBGOAT_FINAL_REPORT.md"
$reportPdf = "c:\webgoat-scripts-1\WEBGOAT_FINAL_REPORT.pdf"

if (Test-Path $reportMd) {
    $reportLines = (Get-Content $reportMd).Count
    Write-Success "Report markdown exists ($reportLines lines)"
    $passedChecks++
    
    if ($reportLines -ge 500) {
        Write-Success "Report has comprehensive content (≥500 lines)"
        $passedChecks++
    } else {
        Write-Warning "Report seems short ($reportLines lines < 500)"
        $issues += "Report may need more content"
    }
} else {
    Write-Error "Report markdown not found: $reportMd"
    $issues += "Missing: WEBGOAT_FINAL_REPORT.md"
}

if (Test-Path $reportPdf) {
    $pdfSize = [math]::Round((Get-Item $reportPdf).Length / 1MB, 2)
    Write-Success "Report PDF exists (${pdfSize}MB)"
    $passedChecks++
} else {
    Write-Error "Report PDF not found - needs conversion"
    $issues += "Missing: WEBGOAT_FINAL_REPORT.pdf"
    Write-Info "   Run: Convert WEBGOAT_FINAL_REPORT.md to PDF"
}

# Check 3: Screenshots
Write-Section "Screenshots Status"
$totalChecks += 2

$screenshotPath = "c:\webgoat-scripts-1\screenshots"
if (Test-Path $screenshotPath) {
    $screenshots = Get-ChildItem -Path $screenshotPath -Filter "*.png" -ErrorAction SilentlyContinue
    $screenshotCount = $screenshots.Count
    
    Write-Info "Found $screenshotCount screenshot(s)"
    
    if ($screenshotCount -eq 8) {
        Write-Success "All 8 required screenshots captured! 📸"
        $passedChecks += 2
        
        # List screenshots
        foreach ($ss in $screenshots) {
            $size = [math]::Round($ss.Length / 1KB, 2)
            Write-Host "   📷 $($ss.Name) (${size}KB)" -ForegroundColor Gray
        }
    } elseif ($screenshotCount -gt 0) {
        Write-Warning "Only $screenshotCount of 8 screenshots present"
        $passedChecks++
        $issues += "Need $(8 - $screenshotCount) more screenshot(s)"
        
        # Expected filenames
        $expected = @(
            "01_webgoat_homepage.png",
            "02_field_restrictions_interface.png",
            "03_powershell_challenge1.png",
            "04_challenge1_success.png",
            "05_input_validation_interface.png",
            "06_powershell_challenge2.png",
            "07_challenge2_success.png",
            "08_progress_dashboard.png"
        )
        
        Write-Info "   Missing screenshots:"
        foreach ($exp in $expected) {
            if (-not (Test-Path "$screenshotPath\$exp")) {
                Write-Host "      • $exp" -ForegroundColor Red
            }
        }
    } else {
        Write-Error "No screenshots found!"
        $issues += "Missing: All 8 screenshots"
        Write-Info "   Run: .\screenshot_helper.ps1"
    }
} else {
    Write-Error "Screenshots folder doesn't exist"
    $issues += "Missing: screenshots folder"
    Write-Info "   Run: mkdir c:\webgoat-scripts-1\screenshots"
}

# Check 4: Video Recording
Write-Section "Video Recording Status"
$totalChecks += 2

$videoFiles = Get-ChildItem "c:\webgoat-scripts-1\*.mp4" -ErrorAction SilentlyContinue
if ($videoFiles) {
    $video = $videoFiles[0]
    $videoSize = [math]::Round($video.Length / 1MB, 2)
    $videoDuration = "Unknown" # PowerShell can't easily get video duration without external tools
    
    Write-Success "Video file found: $($video.Name)"
    $passedChecks++
    
    if ($videoSize -gt 10 -and $videoSize -lt 500) {
        Write-Success "Video size looks reasonable (${videoSize}MB)"
        $passedChecks++
    } elseif ($videoSize -lt 10) {
        Write-Warning "Video seems too small (${videoSize}MB) - may be too short"
        $issues += "Video may be too short (< 5 minutes)"
    } else {
        Write-Warning "Video is very large (${videoSize}MB) - may need compression"
        $issues += "Video may be too large - consider compressing"
    }
    
    Write-Info "   Video: $($video.Name) (${videoSize}MB)"
} else {
    Write-Error "No video file found (.mp4)"
    $issues += "Missing: Live demonstration video"
    Write-Info "   Record using OBS Studio or Windows Game Bar"
}

# Check 5: Progress JSON
Write-Section "WebGoat Progress Status"
$totalChecks += 1

$progressJson = "c:\webgoat-scripts-1\webgoat_progress.json"
if (Test-Path $progressJson) {
    Write-Success "Progress JSON exists"
    $passedChecks++
    
    # Validate JSON structure
    try {
        $progress = Get-Content $progressJson | ConvertFrom-Json
        Write-Info "   Contains: $($progress.completed_challenges.Count) challenge(s)"
    } catch {
        Write-Warning "JSON file may be malformed"
    }
} else {
    Write-Error "Progress JSON not found"
    $issues += "Missing: webgoat_progress.json"
    Write-Info "   Run: .\organize_deliverables.ps1 (auto-generates)"
}

# Check 6: Google Drive Upload Folder
Write-Section "Google Drive Upload Preparation"
$totalChecks += 2

$uploadFolder = Get-ChildItem "c:\webgoat-scripts-1\GoogleDrive_Upload\*_WebGoat" -Directory -ErrorAction SilentlyContinue
if ($uploadFolder) {
    Write-Success "Google Drive upload folder exists: $($uploadFolder.Name)"
    $passedChecks++
    
    # Check contents
    $uploadFiles = Get-ChildItem $uploadFolder.FullName -Recurse -File
    Write-Info "   Contains $($uploadFiles.Count) file(s) ready for upload"
    
    # Check for key files
    $hasReport = $uploadFiles | Where-Object { $_.Name -like "*Report.pdf" }
    $hasVideo = $uploadFiles | Where-Object { $_.Extension -eq ".mp4" }
    $hasProgress = $uploadFiles | Where-Object { $_.Name -eq "webgoat_progress.json" }
    $hasScreenshots = $uploadFiles | Where-Object { $_.Directory.Name -eq "screenshots" }
    
    if ($hasReport -and $hasVideo -and $hasProgress -and $hasScreenshots) {
        Write-Success "All key deliverables present in upload folder"
        $passedChecks++
    } else {
        Write-Warning "Some deliverables missing from upload folder"
        if (-not $hasReport) { Write-Host "      • Report PDF" -ForegroundColor Red }
        if (-not $hasVideo) { Write-Host "      • Video file" -ForegroundColor Red }
        if (-not $hasProgress) { Write-Host "      • Progress JSON" -ForegroundColor Red }
        if (-not $hasScreenshots) { Write-Host "      • Screenshots" -ForegroundColor Red }
        $issues += "Upload folder incomplete"
    }
} else {
    Write-Error "Google Drive upload folder not created"
    $issues += "Missing: Google Drive upload folder"
    Write-Info "   Run: .\organize_deliverables.ps1"
}

# Check 7: Documentation and Guides
Write-Section "Supporting Documentation"
$totalChecks += 3

$docs = @(
    @{Name="Next Steps Guide"; Path="c:\webgoat-scripts-1\NEXT_STEPS_GUIDE.md"},
    @{Name="Final Checklist"; Path="c:\webgoat-scripts-1\FINAL_CHECKLIST.md"},
    @{Name="Screenshot Helper"; Path="c:\webgoat-scripts-1\screenshot_helper.ps1"}
)

foreach ($doc in $docs) {
    if (Test-Path $doc.Path) {
        Write-Success "$($doc.Name) available"
        $passedChecks++
    } else {
        Write-Warning "$($doc.Name) not found (optional)"
    }
}

# Calculate Score
Write-Section "Verification Results"

$percentage = [math]::Round(($passedChecks / $totalChecks) * 100, 1)

Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         READINESS SCORE                 ║" -ForegroundColor Cyan
Write-Host "║                                         ║" -ForegroundColor Cyan
Write-Host "║   $passedChecks / $totalChecks checks passed" -ForegroundColor $(if ($percentage -ge 80) { "Green" } elseif ($percentage -ge 60) { "Yellow" } else { "Red" })
Write-Host "║                                         ║" -ForegroundColor Cyan
Write-Host "║   Readiness: $percentage%                    ║" -ForegroundColor $(if ($percentage -ge 80) { "Green" } elseif ($percentage -ge 60) { "Yellow" } else { "Red" })
Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Readiness Assessment
if ($percentage -eq 100) {
    Write-Host "🎉 EXCELLENT! All deliverables are ready for submission!" -ForegroundColor Green
    Write-Host "`nYou can now:" -ForegroundColor Yellow
    Write-Host "   1. Upload to Google Drive" -ForegroundColor White
    Write-Host "   2. Share folder with instructor" -ForegroundColor White
    Write-Host "   3. Submit Google Drive link" -ForegroundColor White
    Write-Host "`n📧 Use the email template in FINAL_CHECKLIST.md`n" -ForegroundColor Cyan
} elseif ($percentage -ge 80) {
    Write-Host "✅ GOOD! Almost ready for submission." -ForegroundColor Green
    Write-Host "`nAddress the remaining items below, then you're good to go!`n" -ForegroundColor Yellow
} elseif ($percentage -ge 60) {
    Write-Host "⚠️  PARTIAL: Several items still need attention." -ForegroundColor Yellow
    Write-Host "`nFocus on completing the missing items below.`n" -ForegroundColor White
} else {
    Write-Host "❌ NOT READY: Many required items are missing." -ForegroundColor Red
    Write-Host "`nPlease complete the items below before submission.`n" -ForegroundColor White
}

# Issues Summary
if ($issues.Count -gt 0) {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
    Write-Host "   ITEMS NEEDING ATTENTION ($($issues.Count))" -ForegroundColor Red
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Red
    
    $issueNum = 1
    foreach ($issue in $issues) {
        Write-Host "$issueNum. $issue" -ForegroundColor Red
        $issueNum++
    }
    Write-Host ""
}

# Recommendations
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "   RECOMMENDED NEXT STEPS" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan

if (-not (Test-Path "c:\webgoat-scripts-1\screenshots\*.png")) {
    Write-Host "1️⃣  Capture Screenshots (PRIORITY HIGH)" -ForegroundColor Yellow
    Write-Host "   Run: .\screenshot_helper.ps1" -ForegroundColor White
    Write-Host ""
}

if (-not (Test-Path "c:\webgoat-scripts-1\*.mp4")) {
    Write-Host "2️⃣  Record Demo Video (PRIORITY HIGH)" -ForegroundColor Yellow
    Write-Host "   Use OBS Studio or Windows Game Bar" -ForegroundColor White
    Write-Host "   Duration: 5-10 minutes with narration" -ForegroundColor White
    Write-Host ""
}

if (-not (Test-Path "c:\webgoat-scripts-1\WEBGOAT_FINAL_REPORT.pdf")) {
    Write-Host "3️⃣  Convert Report to PDF (PRIORITY HIGH)" -ForegroundColor Yellow
    Write-Host "   Use VS Code Markdown PDF extension" -ForegroundColor White
    Write-Host "   Or copy to Word and save as PDF" -ForegroundColor White
    Write-Host ""
}

if (-not (Get-ChildItem "c:\webgoat-scripts-1\GoogleDrive_Upload\*_WebGoat" -Directory -ErrorAction SilentlyContinue)) {
    Write-Host "4️⃣  Organize Files for Upload (PRIORITY HIGH)" -ForegroundColor Yellow
    Write-Host "   Run: .\organize_deliverables.ps1" -ForegroundColor White
    Write-Host ""
}

Write-Host "5️⃣  Upload to Google Drive (After completing above)" -ForegroundColor Cyan
Write-Host "   • Go to drive.google.com" -ForegroundColor White
Write-Host "   • Upload the folder from GoogleDrive_Upload\" -ForegroundColor White
Write-Host "   • Share with 'Anyone with link can view'" -ForegroundColor White
Write-Host ""

Write-Host "6️⃣  Submit to Instructor (FINAL STEP)" -ForegroundColor Green
Write-Host "   • Use email template from FINAL_CHECKLIST.md" -ForegroundColor White
Write-Host "   • Include your Google Drive link" -ForegroundColor White
Write-Host "   • Double-check link works before sending" -ForegroundColor White
Write-Host ""

# Quick reference
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
Write-Host "   QUICK REFERENCE" -ForegroundColor Magenta
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Magenta

Write-Host "Helper Scripts:" -ForegroundColor Yellow
Write-Host "   .\screenshot_helper.ps1       - Guide for capturing screenshots" -ForegroundColor White
Write-Host "   .\organize_deliverables.ps1   - Organize files for Google Drive" -ForegroundColor White
Write-Host "   .\verify_submission.ps1       - This verification script" -ForegroundColor White
Write-Host ""

Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "   NEXT_STEPS_GUIDE.md           - Detailed task instructions" -ForegroundColor White
Write-Host "   FINAL_CHECKLIST.md            - Complete submission checklist" -ForegroundColor White
Write-Host "   WEBGOAT_FINAL_REPORT.md       - Your comprehensive report" -ForegroundColor White
Write-Host ""

Write-Host "Attack Scripts:" -ForegroundColor Yellow
Write-Host "   bypass_field_restrictions.ps1  - Challenge #1 exploit" -ForegroundColor White
Write-Host "   frontend_validation_attack.ps1 - Challenge #2 exploit" -ForegroundColor White
Write-Host ""

# Footer
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "`n📞 Need help? Review NEXT_STEPS_GUIDE.md for detailed instructions.`n" -ForegroundColor Yellow

Write-Host "Verification complete! Good luck with your submission! 🎓🔒`n" -ForegroundColor Green
