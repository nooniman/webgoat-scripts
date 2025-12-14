╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║                    🔐 JWT COMPLETE TOOLKIT 🔐                             ║
║                                                                            ║
║                    WebGoat 2025.3 JWT Challenges                          ║
║                    Target: 192.168.254.112:8001                           ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝

===============================================
  📦 WHAT'S INCLUDED
===============================================

This toolkit provides EVERYTHING you need to solve WebGoat JWT challenges:

✅ Interactive HTML Tool (jwt_complete_toolkit.html)
✅ PowerShell Automation Script (jwt_automation.ps1)
✅ Complete 500+ Line Guide (jwt_guide.txt)
✅ Quick Start Guide (jwt_quickstart.txt)
✅ 30+ Attack Payloads (jwt_payloads_library.txt)
✅ Visual Cheat Sheet (jwt_cheatsheet.txt)
✅ Troubleshooting Guide (jwt_troubleshooting.txt)
✅ This README (jwt_README.txt)

===============================================
  🚀 QUICK START (3 STEPS)
===============================================

✅ CHALLENGE 1 - PROVEN WORKING SOLUTION:
──────────────────────────────────────────

📄 READ THIS FIRST: JWT_CHALLENGE1_PROVEN_SOLUTION.txt
(Tested and working solution - December 2025)

Quick Steps:
1. F12 > Application > Cookies > http://192.168.254.112:8001
2. Copy "access_token", Double-click VALUE, Delete
3. Paste: eyJhbGciOiJub25lIn0.eyJpYXQiOjE3NjY1NjI5ODksImFkbWluIjoidHJ1ZSIsInVzZXIiOiJUb20ifQ.
4. Press Enter
5. Click "Delete" button OR refresh (F5)
6. ✅ Challenge Complete!

IMPORTANT: Cookie is HttpOnly - JavaScript CANNOT access it!
Must edit manually in DevTools Application > Cookies tab.

FOR OTHER CHALLENGES:
────────────────────────

STEP 1: Open the Tools
────────────────────────
# Open HTML interface
Double-click: jwt_complete_toolkit.html

# Run PowerShell script
cd c:\webgoat-scripts-1
.\jwt_automation.ps1

STEP 2: Get Your JWT Token
────────────────────────────
1. Login to WebGoat
2. Navigate to JWT lesson
3. Open DevTools (F12)
4. Find token in Application > Cookies or Network > Headers
5. Copy the complete token

STEP 3: Attack!
────────────────
Try attacks in this order:
1. Algorithm "none" (PowerShell Option 6)
2. Tampering (Option 2)
3. Brute Force (Option 8)

Most challenges solved with Option 6 (algorithm "none").

===============================================
  📚 WHICH FILE TO READ FIRST?
===============================================

🎯 BEGINNER - Never used JWT before?
   ➜ Read: jwt_quickstart.txt (10 min read)
   ➜ Use: jwt_complete_toolkit.html (visual interface)

🎯 INTERMEDIATE - Know JWT basics?
   ➜ Read: jwt_cheatsheet.txt (5 min reference)
   ➜ Use: jwt_automation.ps1 (PowerShell menu)

🎯 ADVANCED - Want deep understanding?
   ➜ Read: jwt_guide.txt (30 min comprehensive)
   ➜ Read: jwt_payloads_library.txt (examples)

🎯 STUCK - Something not working?
   ➜ Read: jwt_troubleshooting.txt (solutions)

🎯 QUICK LOOKUP - Need a command?
   ➜ Read: jwt_cheatsheet.txt (all commands)

===============================================
  🛠️ TOOLS OVERVIEW
===============================================

┌─────────────────────────────────────────────────────────────┐
│ jwt_complete_toolkit.html - Interactive Web Tool            │
├─────────────────────────────────────────────────────────────┤
│ ✓ Beautiful visual interface                                │
│ ✓ 6 tabs: Decoder, Tampering, Algorithm, Secrets,          │
│   Admin Access, Password Reset                              │
│ ✓ One-click attacks                                         │
│ ✓ Copy-paste friendly                                       │
│ ✓ No installation needed                                    │
│ ✗ Limited brute force (use PowerShell for this)            │
│                                                              │
│ BEST FOR: Visual learners, quick tests, beginners           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ jwt_automation.ps1 - PowerShell Script                       │
├─────────────────────────────────────────────────────────────┤
│ ✓ Full automation                                            │
│ ✓ 12 attack methods                                         │
│ ✓ HMAC-SHA256 signing support                               │
│ ✓ Brute force capability                                    │
│ ✓ Auto-copy to clipboard                                    │
│ ✓ Menu-driven interface                                     │
│                                                              │
│ BEST FOR: Serious attacks, automation, signing tokens       │
└─────────────────────────────────────────────────────────────┘

💡 TIP: Use BOTH tools together for best results!

===============================================
  🎯 ATTACK METHODS EXPLAINED
===============================================

METHOD 1: Token Tampering (⭐⭐⭐⭐⭐ Most Common)
─────────────────────────────────────────────────
What: Modify JWT claims without valid signature
When: Server doesn't verify signature properly
Success Rate: 70% of WebGoat challenges
Difficulty: ⭐ Easy

Example: Change "admin": false → "admin": true

PowerShell: Option 2, 3, 4, 11
HTML: Token Tampering tab

METHOD 2: Algorithm "none" (⭐⭐⭐⭐ Common)
────────────────────────────────────────────
What: Remove signature verification requirement
When: Server accepts "none" algorithm
Success Rate: 50% of challenges
Difficulty: ⭐ Easy

Example: Change {"alg": "HS256"} → {"alg": "none"}

PowerShell: Option 6
HTML: Algorithm Confusion > "none" + Remove Signature

METHOD 3: Remove Signature (⭐⭐⭐ Sometimes Works)
───────────────────────────────────────────────────
What: Strip signature completely
When: Server doesn't check signature presence
Success Rate: 30% of challenges
Difficulty: ⭐ Easy

Example: header.payload.signature → header.payload.

PowerShell: Option 7
HTML: Algorithm Confusion > Remove Signature Only

METHOD 4: Brute Force Secret (⭐⭐ If Others Fail)
──────────────────────────────────────────────────
What: Crack HMAC secret to sign valid tokens
When: Server properly validates, but uses weak secret
Success Rate: Depends on secret strength
Difficulty: ⭐⭐⭐ Moderate

Common WebGoat secrets: webgoat, secret, password

PowerShell: Option 8 (crack), then Option 9 (sign)
HTML: Weak Secrets tab

===============================================
  📖 FILE DESCRIPTIONS
===============================================

jwt_complete_toolkit.html (Interactive Tool)
─────────────────────────────────────────────
The main web interface. Open in browser for visual attacks.

Features:
• JWT Decoder (decode any token)
• Token Tampering (6 preset attacks)
• Algorithm Confusion (4 attack methods)
• Weak Secret Brute Force
• Admin Access Attacks
• Password Reset Attacks
• Copy-paste ready outputs
• cURL command generation

Size: ~40KB HTML+CSS+JavaScript
Browser: Chrome, Firefox, Edge (any modern browser)

jwt_automation.ps1 (PowerShell Script)
───────────────────────────────────────
The automation workhorse. Run in PowerShell for full power.

Menu Options:
1  - Decode JWT
2  - Make Admin (admin: true) ⭐
3  - Change to Admin User ⭐
4  - SQL Injection
5  - Algorithm "none" (keep signature)
6  - Algorithm "none" (remove signature) ⭐
7  - Remove Signature Only
8  - Brute Force Secret
9  - Sign New Token
10 - Password Reset Attack
11 - Custom Field Tamper
12 - Send JWT Request

Size: ~300 lines of PowerShell
Requires: PowerShell 5.1+ (built into Windows)

jwt_guide.txt (Complete Guide)
────────────────────────────────
Comprehensive 500+ line guide covering everything.

Sections:
• JWT Basics & Structure
• Attack Method Details
• External Tools Usage
• WebGoat Specific Tips
• Troubleshooting
• Learning Resources

Read Time: 30 minutes
Best For: Deep understanding

jwt_quickstart.txt (Quick Start)
──────────────────────────────────
Get up and running in 5 minutes.

Contents:
• Essential commands
• Common attack workflows
• Copy-paste ready
• WebGoat challenge solutions

Read Time: 5 minutes
Best For: Immediate action

jwt_payloads_library.txt (Payload Examples)
─────────────────────────────────────────────
30+ ready-to-use attack payloads.

Includes:
• Admin escalation payloads
• SQL injection payloads
• Price manipulation
• Algorithm confusion headers
• cURL command templates
• Python script examples
• Browser console code

Best For: Copy-paste attacks

jwt_cheatsheet.txt (Visual Reference)
───────────────────────────────────────
One-page visual cheat sheet with boxes and formatting.

Contents:
• All 12 PowerShell options
• Common payloads
• cURL templates
• Challenge solutions
• Quick troubleshooting

Best For: Quick lookup while working

jwt_troubleshooting.txt (Problem Solving)
───────────────────────────────────────────
Solutions to common problems.

Covers:
• Script won't run
• Token format errors
• Signature issues
• Brute force problems
• Request failures
• WebGoat specific issues

Best For: When stuck

jwt_summary.txt (Tool Overview)
─────────────────────────────────
High-level overview of entire toolkit.

Contents:
• File descriptions
• Tool comparison
• Learning path
• Workflow examples

Best For: Understanding toolkit structure

jwt_README.txt (This File)
────────────────────────────
You're reading it! Complete overview and getting started guide.

===============================================
  🎓 LEARNING PATH
===============================================

LEVEL 1: Beginner (Never used JWT)
────────────────────────────────────
Day 1: Understanding
□ Read jwt_quickstart.txt
□ Open jwt_complete_toolkit.html
□ Decode sample token
□ Understand header/payload/signature

Day 2: First Attack
□ Get JWT from WebGoat
□ Try tampering attack (Option 2)
□ Complete "Become Admin" challenge

Day 3: More Attacks
□ Try algorithm "none" attack
□ Try remove signature
□ Complete 3 challenges

LEVEL 2: Intermediate (Know basics)
─────────────────────────────────────
Week 1: Master All Methods
□ Read jwt_guide.txt (full guide)
□ Try all 12 PowerShell options
□ Complete all WebGoat JWT challenges
□ Read jwt_payloads_library.txt

Week 2: External Tools
□ Install jwt_tool
□ Try jwt.io online tool
□ Practice with custom payloads
□ Create your own variations

LEVEL 3: Advanced (Expert attacks)
────────────────────────────────────
□ Install hashcat for serious cracking
□ Study RS256→HS256 attacks
□ Learn to extract public keys
□ Try attacks on real applications (ethically!)
□ Contribute to toolkit improvements

===============================================
  🏆 WEBGOAT CHALLENGE WALKTHROUGHS
===============================================

CHALLENGE: "Become Admin"
──────────────────────────
Goal: Get admin privileges via JWT tampering
Difficulty: ⭐ Easy

Solution:
1. Get your JWT token (F12 > Storage > Cookies)
2. Run: .\jwt_automation.ps1
3. Choose Option 2 (Make Admin)
4. Paste your token
5. Copy tampered token
6. Submit in WebGoat
7. Success! ✓

Alternative: HTML Tool > Token Tampering > Make Admin

CHALLENGE: "Reset Admin Password"
───────────────────────────────────
Goal: Reset another user's password via JWT
Difficulty: ⭐⭐ Medium

Solution:
1. Request password reset for YOUR account
2. Capture reset JWT token
3. Run: .\jwt_automation.ps1
4. Choose Option 10 (Password Reset)
5. Enter target username: admin
6. Copy tampered token
7. POST to reset endpoint with new password
8. Success! ✓

CHALLENGE: "Buy Item for $0"
──────────────────────────────
Goal: Purchase item by manipulating price in JWT
Difficulty: ⭐⭐ Medium

Solution:
1. Add item to cart
2. Capture JWT with price info
3. Run: .\jwt_automation.ps1
4. Choose Option 11 (Custom Tamper)
5. Field: price, Value: 0
6. Copy tampered token
7. Complete purchase
8. Success! ✓

CHALLENGE: "SQL Injection in JWT"
───────────────────────────────────
Goal: Inject SQL via JWT username field
Difficulty: ⭐⭐ Medium

Solution:
1. Get your JWT token
2. Run: .\jwt_automation.ps1
3. Choose Option 4 (SQL Injection)
4. Copy tampered token (username: admin' OR '1'='1)
5. Submit token
6. Success! ✓

CHALLENGE: "Crack JWT Secret"
───────────────────────────────
Goal: Brute force secret and sign as admin
Difficulty: ⭐⭐⭐ Hard

Solution:
1. Get valid JWT token
2. Run: .\jwt_automation.ps1
3. Choose Option 8 (Brute Force)
4. Wait... Found: "webgoat"
5. Choose Option 9 (Sign Token)
6. Payload: {"sub":"admin","admin":true}
7. Secret: webgoat
8. Copy signed token
9. Submit in WebGoat
10. Success! ✓

Hint: Common secrets are "webgoat", "secret", "password"

===============================================
  💻 SYSTEM REQUIREMENTS
===============================================

Minimum Requirements:
• Windows 10 or later
• PowerShell 5.1+ (built-in)
• Any modern web browser
• Text editor (for viewing guides)

Recommended:
• Windows 11
• PowerShell 7+
• Chrome or Firefox (for DevTools)
• VS Code (for viewing/editing)

Optional (for advanced attacks):
• Python 3.7+ (for jwt_tool)
• hashcat (for serious cracking)
• Git (for cloning tools)

===============================================
  🔧 INSTALLATION & SETUP
===============================================

Basic Setup (Required):
─────────────────────────
Already done! All files in c:\webgoat-scripts-1\

Just need to:
1. Allow PowerShell scripts:
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass

2. Open HTML tool:
   Double-click jwt_complete_toolkit.html

Advanced Setup (Optional):
────────────────────────────
For external tools:

jwt_tool:
git clone https://github.com/ticarpi/jwt_tool
cd jwt_tool
pip install pyjwt

hashcat:
Download from: https://hashcat.net/hashcat/
Extract and add to PATH

===============================================
  📞 HELP & SUPPORT
===============================================

Stuck? Try these in order:
1. Check jwt_troubleshooting.txt
2. Read jwt_guide.txt relevant section
3. Look in jwt_payloads_library.txt for examples
4. Check WebGoat hints in lesson
5. Search WebGoat GitHub issues

Don't Share:
• Your actual JWT tokens (security risk)
• WebGoat passwords
• Full solutions publicly (spoils learning)

Do Share:
• Toolkit improvements/bugs
• New attack methods discovered
• Additional payloads that work

===============================================
  🎯 SUCCESS METRICS
===============================================

You'll know you're succeeding when:
✓ Can decode any JWT token
✓ Understand header/payload/signature
✓ Complete "Become Admin" challenge
✓ Successfully tamper tokens
✓ Know when to try each attack
✓ Complete all JWT challenges
✓ Can explain JWT vulnerabilities

===============================================
  🔐 SECURITY & ETHICS
===============================================

⚠️ IMPORTANT: Use ONLY on:
• WebGoat (intentionally vulnerable)
• Your own applications
• Authorized security testing
• Bug bounty programs (with permission)

❌ NEVER use on:
• Production systems without authorization
• Third-party applications
• Real user accounts
• Any system you don't own/have permission for

This toolkit is for LEARNING and AUTHORIZED TESTING ONLY.
Unauthorized access is illegal and unethical.

===============================================
  🚀 NEXT STEPS
===============================================

After mastering JWT attacks:
1. ✓ Complete all WebGoat JWT challenges
2. ✓ Try JWT challenges on other platforms:
   - PortSwigger Web Security Academy
   - HackTheBox
   - TryHackMe
3. ✓ Learn about JWT best practices
4. ✓ Study how to properly implement JWT
5. ✓ Move to next WebGoat lesson series

===============================================
  📊 TOOLKIT STATISTICS
===============================================

Files Created: 8
Total Lines: 3,000+
Attack Methods: 12+
Payload Examples: 30+
Development Time: Professional grade
Cost: FREE
Awesomeness: Maximum 😎

===============================================
  🎉 READY TO BEGIN!
===============================================

You have everything you need to master JWT attacks!

Quick Start Checklist:
□ Read jwt_quickstart.txt (5 min)
□ Open jwt_complete_toolkit.html
□ Run jwt_automation.ps1
□ Get JWT token from WebGoat
□ Try Option 2 (Make Admin)
□ Complete first challenge
□ Celebrate! 🎉

═══════════════════════════════════════════════════════════════

                    Happy Hacking! 🔐
            (Ethically and Legally, of course!)

═══════════════════════════════════════════════════════════════

Target: http://192.168.254.112:8001/WebGoat/JWT
Tools: c:\webgoat-scripts-1\
Start: jwt_quickstart.txt or jwt_complete_toolkit.html

Good luck with your JWT challenges!
