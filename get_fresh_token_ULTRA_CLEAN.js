// GET FRESH REFRESH TOKEN - ULTRA CLEAN VERSION
// NO SPECIAL CHARACTERS - GUARANTEED TO WORK
// Run this FIRST to get a fresh refresh token

(function() {
    console.log('===================================================');
    console.log('GETTING FRESH REFRESH TOKEN');
    console.log('===================================================');
    
    console.log('[Step 1] Searching page HTML for refresh_token...');
    
    // Search all <p> tags for refresh_token
    const paragraphs = document.querySelectorAll('p');
    for (let p of paragraphs) {
        const text = p.textContent;
        if (text.includes('refresh_token')) {
            const match = text.match(/[a-f0-9]{32,}/);
            if (match) {
                window.myRefreshToken = match[0];
                console.log('[FOUND in HTML] Refresh token: ' + window.myRefreshToken);
                console.log('[OK] Saved to window.myRefreshToken');
                console.log('[NEXT] Now run jwt_refresh_ULTRA_CLEAN.js');
                return;
            }
        }
    }
    
    console.log('[Not Found] No refresh token in HTML yet');
    console.log('[Step 2] Trying to get fresh token from server...');
    
    // Try login endpoint
    fetch('/WebGoat/JWT/refresh/login', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            user: 'Jerry',
            password: 'doesnt-matter'
        })
    })
    .then(response => {
        console.log('[Login Response] Status: ' + response.status);
        if (response.status === 401) {
            console.log('[INFO] 401 - Lesson not initialized');
            console.log('[ACTION REQUIRED] Please click the Checkout button on the page');
            console.log('[THEN] Check Network tab for the response');
            console.log('[LOOK FOR] A field called refresh_token');
            console.log('[MANUAL] Copy it and run: window.myRefreshToken = "YOUR_TOKEN_HERE"');
            return null;
        }
        return response.json();
    })
    .then(data => {
        if (data && data.refresh_token) {
            window.myRefreshToken = data.refresh_token;
            console.log('[SUCCESS] Got refresh token: ' + window.myRefreshToken);
            console.log('[OK] Saved to window.myRefreshToken');
            console.log('[NEXT] Now run jwt_refresh_ULTRA_CLEAN.js');
        }
    })
    .catch(error => {
        console.log('[ERROR] ' + error.message);
        console.log('');
        console.log('===================================================');
        console.log('MANUAL STEPS TO GET REFRESH TOKEN:');
        console.log('===================================================');
        console.log('1. Open DevTools Network tab (F12)');
        console.log('2. Click the "Checkout" button on the page');
        console.log('3. Look for the request to /JWT/refresh/checkout');
        console.log('4. Click on it and view the Response');
        console.log('5. Look for "refresh_token": "..."');
        console.log('6. Copy the long hex string');
        console.log('7. Run: window.myRefreshToken = "PASTE_TOKEN_HERE"');
        console.log('8. Then run jwt_refresh_ULTRA_CLEAN.js');
        console.log('===================================================');
    });
})();
