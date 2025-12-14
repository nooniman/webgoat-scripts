// ═══════════════════════════════════════════════════════════
// JWT REFRESH TOKEN - ENDPOINT DISCOVERY
// Paste this in browser console on WebGoat JWT page
// ═══════════════════════════════════════════════════════════

(async function() {
    console.clear();
    console.log('%c═══════════════════════════════════════════════════════', 'color: cyan; font-size: 14px');
    console.log('%c    JWT REFRESH TOKEN - DIAGNOSTIC TOOL', 'color: yellow; font-size: 16px; font-weight: bold');
    console.log('%c═══════════════════════════════════════════════════════', 'color: cyan; font-size: 14px');
    
    // Tom's expired token
    const TOMS_EXPIRED_TOKEN = 'eyJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE1MjYxMzE0MTEsImV4cCI6MTUyNjIxNzgxMSwiYWRtaW4iOiJmYWxzZSIsInVzZXIiOiJUb20ifQ.DCoaq9zQkyDH25EcVWKcdbyVfUL4c9D4jRvsqOqvi9iAd4QuqmKcchfbU8FNzeBNF9tLeFXHZLU4yRkq-bjm7Q';
    
    console.log('\n%c[STEP 1] Testing Various Endpoints...', 'color: cyan; font-size: 14px; font-weight: bold');
    
    // List of possible endpoints
    const endpoints = [
        '/WebGoat/JWT/refresh/login',
        '/WebGoat/JWT/refresh/checkout',
        '/WebGoat/JWT/refresh/newToken',
        '/WebGoat/login',
        '/login',
        '/WebGoat/JWT/login'
    ];
    
    console.log('Testing endpoints...\n');
    
    for (const endpoint of endpoints) {
        try {
            const resp = await fetch(endpoint, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({user: 'Tom', password: 'test'})
            });
            
            console.log(`%c✓ ${endpoint}`, 'color: green; font-weight: bold');
            console.log(`  Status: ${resp.status} ${resp.statusText}`);
            console.log(`  Content-Type: ${resp.headers.get('content-type')}`);
            
            const text = await resp.text();
            if (text.length < 500) {
                console.log(`  Response: ${text.substring(0, 200)}`);
            } else {
                console.log(`  Response: [HTML page - ${text.length} bytes]`);
            }
        } catch (e) {
            console.log(`%c✗ ${endpoint}`, 'color: red');
            console.log(`  Error: ${e.message}`);
        }
        console.log('');
    }
    
    console.log('\n%c[STEP 2] Checking Current Page for Buttons/Forms...', 'color: cyan; font-size: 14px; font-weight: bold');
    
    // Check for checkout button
    const checkoutBtn = document.querySelector('button[id*="checkout"], button[class*="checkout"], input[value*="checkout"]');
    if (checkoutBtn) {
        console.log('%c✓ Found checkout button:', 'color: green');
        console.log(checkoutBtn);
    } else {
        console.log('%c✗ No checkout button found', 'color: orange');
    }
    
    // Check for any JWT-related inputs
    const jwtInputs = document.querySelectorAll('input[name*="token"], input[id*="token"], textarea[name*="token"]');
    if (jwtInputs.length > 0) {
        console.log(`%c✓ Found ${jwtInputs.length} token input(s):`, 'color: green');
        jwtInputs.forEach(input => console.log(input));
    } else {
        console.log('%c✗ No token inputs found', 'color: orange');
    }
    
    console.log('\n%c[STEP 3] Checking Cookies and Storage...', 'color: cyan; font-size: 14px; font-weight: bold');
    
    // Check cookies
    console.log('Cookies:', document.cookie || '(none)');
    
    // Check localStorage
    if (localStorage.length > 0) {
        console.log('localStorage items:');
        for (let i = 0; i < localStorage.length; i++) {
            const key = localStorage.key(i);
            const value = localStorage.getItem(key);
            console.log(`  ${key}: ${value.substring(0, 50)}...`);
        }
    } else {
        console.log('localStorage: (empty)');
    }
    
    // Check sessionStorage
    if (sessionStorage.length > 0) {
        console.log('sessionStorage items:');
        for (let i = 0; i < sessionStorage.length; i++) {
            const key = sessionStorage.key(i);
            const value = sessionStorage.getItem(key);
            console.log(`  ${key}: ${value.substring(0, 50)}...`);
        }
    } else {
        console.log('sessionStorage: (empty)');
    }
    
    console.log('\n%c[STEP 4] Looking for Existing Tokens in Page Source...', 'color: cyan; font-size: 14px; font-weight: bold');
    
    // Search page HTML for JWT patterns
    const html = document.documentElement.innerHTML;
    const jwtPattern = /eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*/g;
    const foundTokens = html.match(jwtPattern);
    
    if (foundTokens && foundTokens.length > 0) {
        console.log(`%c✓ Found ${foundTokens.length} JWT token(s) in page:`, 'color: green');
        foundTokens.slice(0, 3).forEach((token, i) => {
            console.log(`  Token ${i + 1}: ${token.substring(0, 50)}...`);
        });
    } else {
        console.log('%c✗ No JWT tokens found in page HTML', 'color: orange');
    }
    
    console.log('\n%c[STEP 5] Testing Direct Checkout with Tom\'s Token...', 'color: cyan; font-size: 14px; font-weight: bold');
    
    try {
        const resp = await fetch('/WebGoat/JWT/refresh/checkout', {
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + TOMS_EXPIRED_TOKEN,
                'Content-Type': 'application/json'
            }
        });
        
        console.log(`Status: ${resp.status} ${resp.statusText}`);
        const text = await resp.text();
        
        if (resp.ok) {
            console.log('%c✓ Checkout succeeded with Tom\'s expired token!', 'color: green; font-weight: bold');
            console.log('Response:', text);
        } else {
            console.log('%c✗ Checkout failed (expected):', 'color: orange');
            console.log('Response:', text.substring(0, 200));
        }
    } catch (e) {
        console.log('%c✗ Checkout error:', 'color: red');
        console.log(e);
    }
    
    console.log('\n%c═══════════════════════════════════════════════════════', 'color: cyan; font-size: 14px');
    console.log('%c    DIAGNOSTIC COMPLETE', 'color: yellow; font-size: 16px; font-weight: bold');
    console.log('%c═══════════════════════════════════════════════════════', 'color: cyan; font-size: 14px');
    
    console.log('\n%c💡 NEXT STEPS:', 'color: orange; font-size: 14px; font-weight: bold');
    console.log('1. Check the lesson page - you may need to click a button first');
    console.log('2. Look for a "Login" or "Get Token" button on the page');
    console.log('3. The lesson might require you to interact with the UI first');
    console.log('4. Check Network tab (F12) when you click buttons to see actual endpoints');
    
})();
