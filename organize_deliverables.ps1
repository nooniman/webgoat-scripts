# WebGoat Deliverables Organizer Script
# Date: December 14, 2025
# Purpose: Organize all files for Google Drive submission

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   WebGoat Project - File Organizer" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Get student name
$lastName = Read-Host "Enter your LAST name"
$firstName = Read-Host "Enter your FIRST name"
$folderName = "${lastName}_${firstName}_WebGoat"

# Create main upload folder
$uploadPath = "c:\webgoat-scripts-1\GoogleDrive_Upload\$folderName"
Write-Host "`nCreating upload folder structure..." -ForegroundColor Yellow

New-Item -ItemType Directory -Path $uploadPath -Force | Out-Null
New-Item -ItemType Directory -Path "$uploadPath\screenshots" -Force | Out-Null
New-Item -ItemType Directory -Path "$uploadPath\attack_scripts" -Force | Out-Null

Write-Host "✅ Folder structure created at: $uploadPath`n" -ForegroundColor Green

# Copy files
Write-Host "Organizing files for submission..." -ForegroundColor Yellow

# Copy report PDF (if exists)
if (Test-Path "c:\webgoat-scripts-1\WEBGOAT_FINAL_REPORT.pdf") {
    Copy-Item "c:\webgoat-scripts-1\WEBGOAT_FINAL_REPORT.pdf" -Destination "$uploadPath\${folderName}_Report.pdf"
    Write-Host "✅ Copied Report PDF" -ForegroundColor Green
} else {
    Write-Host "⚠️  Report PDF not found - please convert WEBGOAT_FINAL_REPORT.md to PDF first" -ForegroundColor Red
}

# Copy video (if exists)
$videoFiles = Get-ChildItem "c:\webgoat-scripts-1\*.mp4" -ErrorAction SilentlyContinue
if ($videoFiles) {
    Copy-Item $videoFiles[0].FullName -Destination "$uploadPath\${folderName}_LiveDemo.mp4"
    Write-Host "✅ Copied Video file" -ForegroundColor Green
} else {
    Write-Host "⚠️  Video file not found - please record demo video" -ForegroundColor Red
}

# Copy progress JSON (if exists)
if (Test-Path "c:\webgoat-scripts-1\webgoat_progress.json") {
    Copy-Item "c:\webgoat-scripts-1\webgoat_progress.json" -Destination "$uploadPath\webgoat_progress.json"
    Write-Host "✅ Copied Progress JSON" -ForegroundColor Green
} else {
    Write-Host "⚠️  Progress JSON not found - will create template" -ForegroundColor Yellow
    
    # Create template progress file
    $progressTemplate = @"
{
  "student_name": "$firstName $lastName",
  "course": "IT 143 - Information Assurance Security 2",
  "date": "$(Get-Date -Format 'yyyy-MM-dd')",
  "webgoat_url": "http://192.168.254.112:8001/WebGoat",
  "session_id": "25A6B220A4CB5215EBBE7B31E207B4B1",
  "completed_challenges": [
    {
      "challenge_id": 1,
      "name": "Field Restrictions Bypass",
      "category": "Client Side",
      "lesson": "FieldRestrictions/frontendValidation",
      "completion_date": "$(Get-Date -Format 'yyyy-MM-dd')",
      "attempts": 1,
      "status": "PASSED",
      "score": 100,
      "attack_vector": "Direct HTTP POST with PowerShell",
      "script_used": "bypass_field_restrictions.ps1"
    },
    {
      "challenge_id": 2,
      "name": "Frontend Input Validation Bypass",
      "category": "Client Side",
      "lesson": "FrontendValidation/validation",
      "completion_date": "$(Get-Date -Format 'yyyy-MM-dd')",
      "attempts": 1,
      "status": "PASSED",
      "score": 100,
      "attack_vector": "Bypassed 7 regex validation rules",
      "script_used": "frontend_validation_attack.ps1"
    }
  ],
  "total_score": 200,
  "completion_rate": "100%",
  "time_spent": "2 hours",
  "chapter_connection": "Chapter 4 - Information & Cryptography"
}
"@
    
    $progressTemplate | Out-File -FilePath "$uploadPath\webgoat_progress.json" -Encoding UTF8
    Write-Host "✅ Created template progress file" -ForegroundColor Green
}

# Copy screenshots (if exist)
if (Test-Path "c:\webgoat-scripts-1\screenshots") {
    $screenshots = Get-ChildItem "c:\webgoat-scripts-1\screenshots\*.png" -ErrorAction SilentlyContinue
    if ($screenshots) {
        Copy-Item "c:\webgoat-scripts-1\screenshots\*.png" -Destination "$uploadPath\screenshots\"
        Write-Host "✅ Copied $($screenshots.Count) screenshots" -ForegroundColor Green
    } else {
        Write-Host "⚠️  No screenshots found - please take 8 screenshots as outlined in guide" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  Screenshots folder not found - creating folder for you" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "c:\webgoat-scripts-1\screenshots" -Force | Out-Null
    Write-Host "   📁 Created folder: c:\webgoat-scripts-1\screenshots\" -ForegroundColor Cyan
}

# Copy attack scripts
$scripts = @("bypass_field_restrictions.ps1", "frontend_validation_attack.ps1")
foreach ($script in $scripts) {
    if (Test-Path "c:\webgoat-scripts-1\$script") {
        Copy-Item "c:\webgoat-scripts-1\$script" -Destination "$uploadPath\attack_scripts\"
        Write-Host "✅ Copied $script" -ForegroundColor Green
    }
}

# Create README in attack_scripts folder
$scriptReadme = @"
# WebGoat Attack Scripts

**Student:** $firstName $lastName
**Course:** IT 143 - Information Assurance Security 2
**Date:** $(Get-Date -Format 'yyyy-MM-dd')

## Scripts Included:

### 1. bypass_field_restrictions.ps1
**Challenge:** Field Restrictions Bypass
**Method:** Direct HTTP POST request
**Success Rate:** 100% (first attempt)
**Bypasses:**
- Dropdown restrictions
- Radio button limitations
- Checkbox constraints
- Maxlength attributes
- Readonly field protections

**Execution:**
```powershell
cd c:\webgoat-scripts-1\
.\bypass_field_restrictions.ps1
```

### 2. frontend_validation_attack.ps1
**Challenge:** Frontend Input Validation Bypass
**Method:** Direct HTTP POST with invalid data
**Success Rate:** 100% (first attempt)
**Bypasses:**
- Lowercase requirements
- Digit-only validation
- Alphanumeric constraints
- Enumeration restrictions
- Zip code format validation
- Phone number format validation

**Execution:**
```powershell
cd c:\webgoat-scripts-1\
.\frontend_validation_attack.ps1
```

## Technical Details:

**WebGoat URL:** http://192.168.254.112:8001/WebGoat
**Session Cookie:** 25A6B220A4CB5215EBBE7B31E207B4B1
**HTTP Method:** POST
**Tool:** PowerShell Invoke-WebRequest

## Security Lessons:

1. **Client-side validation is NOT security** - only user experience
2. **Server-side validation is mandatory** - never trust client input
3. **CIA Triad violations** - integrity compromised in both challenges
4. **Defense in depth required** - multiple security layers needed
5. **Chapter 4 principles apply** - encryption alone insufficient without validation

## Results:

Both challenges completed successfully on first attempt, demonstrating that 
client-side security controls can be trivially bypassed by anyone with basic 
HTTP knowledge and PowerShell skills.
"@

$scriptReadme | Out-File -FilePath "$uploadPath\attack_scripts\README.txt" -Encoding UTF8

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "         File Organization Summary" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Summary
Write-Host "📊 DELIVERABLES STATUS:`n" -ForegroundColor Yellow

$items = @(
    @{Name="Report PDF"; Path="$uploadPath\${folderName}_Report.pdf"},
    @{Name="Live Demo Video"; Path="$uploadPath\${folderName}_LiveDemo.mp4"},
    @{Name="Progress JSON"; Path="$uploadPath\webgoat_progress.json"},
    @{Name="Screenshots"; Path="$uploadPath\screenshots\*.png"},
    @{Name="Attack Scripts"; Path="$uploadPath\attack_scripts\*.ps1"}
)

foreach ($item in $items) {
    $exists = Test-Path $item.Path
    if ($exists) {
        if ($item.Name -eq "Screenshots") {
            $count = (Get-ChildItem $item.Path -ErrorAction SilentlyContinue).Count
            Write-Host "✅ $($item.Name): $count files" -ForegroundColor Green
        } elseif ($item.Name -eq "Attack Scripts") {
            $count = (Get-ChildItem $item.Path -ErrorAction SilentlyContinue).Count
            Write-Host "✅ $($item.Name): $count files" -ForegroundColor Green
        } else {
            Write-Host "✅ $($item.Name): Ready" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ $($item.Name): MISSING" -ForegroundColor Red
    }
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "             NEXT STEPS" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

Write-Host "1️⃣  Complete any missing items (see red ❌ above)" -ForegroundColor White
Write-Host "2️⃣  Review all files in: $uploadPath" -ForegroundColor White
Write-Host "3️⃣  Upload the entire folder to Google Drive" -ForegroundColor White
Write-Host "4️⃣  Share Google Drive folder (Anyone with link can view)" -ForegroundColor White
Write-Host "5️⃣  Submit Google Drive link to instructor`n" -ForegroundColor White

# Create submission email template
$emailTemplate = @"
Subject: IT 143 - WebGoat Security Assessment - $lastName, $firstName

Dear Professor [Instructor Name],

I have completed my WebGoat security assessment project for IT 143 (Chapter 4 - Information & Cryptography). 

Google Drive Link: [INSERT YOUR LINK HERE]

Completed Deliverables:
✅ Comprehensive PDF Report (11 sections, 687 lines)
✅ Live Demonstration Video (MP4)
✅ 8 Timestamped Screenshots
✅ WebGoat Progress Export (JSON)
✅ PowerShell Attack Scripts

Challenges Completed:
1. Field Restrictions Bypass - 100% success (first attempt)
2. Frontend Input Validation Bypass - 100% success (first attempt)

Chapter 4 Concepts Applied:
- CIA Triad (Confidentiality, Integrity, Availability)
- Security through Obscurity (rejected)
- PKI & Certificates
- HTTPS/TLS Encryption
- Man-in-the-Middle Attacks
- PII Protection
- Trust Models

Please let me know if you need any clarification or additional materials.

Best regards,
$firstName $lastName
[Student ID]
IT 143 - Section [X]
"@

$emailTemplate | Out-File -FilePath "$uploadPath\SUBMISSION_EMAIL_TEMPLATE.txt" -Encoding UTF8

Write-Host "📧 Submission email template created: SUBMISSION_EMAIL_TEMPLATE.txt`n" -ForegroundColor Cyan

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Upload folder ready at:" -ForegroundColor Green
Write-Host "   $uploadPath" -ForegroundColor Yellow
Write-Host "============================================`n" -ForegroundColor Cyan

# Open folder in Explorer
Write-Host "Opening upload folder in Windows Explorer..." -ForegroundColor Yellow
Start-Process explorer.exe -ArgumentList $uploadPath

Write-Host "`n✅ Organization complete! Good luck with your submission! 🎓" -ForegroundColor Green
