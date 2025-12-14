// AUTO-CLICK CHECKOUT TO GET FRESH REFRESH TOKEN
// This will automatically click the Checkout button and capture the refresh token

(function() {
    console.log('===================================================================');
    console.log('AUTO-GETTING FRESH REFRESH TOKEN');
    console.log('===================================================================');
    
    // Step 1: Find and click the Checkout button
    console.log('\n[Step 1] Looking for Checkout button...');
    
    const buttons = document.querySelectorAll('button');
    let checkoutButton = null;
    
    for (let btn of buttons) {
        if (btn.textContent.includes('Checkout')) {
            checkoutButton = btn;
            console.log('FOUND Checkout button!');
            break;
        }
    }
    
    if (!checkoutButton) {
        console.log('ERROR: Could not find Checkout button');
        console.log('MANUAL STEP: Click the Checkout button yourself');
        console.log('Then check Network tab for the refresh_token in the response');
        return;
    }
    
    // Step 2: Set up network listener BEFORE clicking
    console.log('\n[Step 2] Setting up network listener...');
    
    const originalFetch = window.fetch;
    window.fetch = function(...args) {
        return originalFetch.apply(this, args).then(response => {
            // Clone response so we can read it
            const clonedResponse = response.clone();
            
            // Check if this is the checkout endpoint
            if (args[0].includes('/JWT/refresh/checkout')) {
                console.log('\n[INTERCEPTED] Checkout response!');
                clonedResponse.json().then(data => {
                    console.log('Response data:', JSON.stringify(data, null, 2));
                    
                    if (data.refresh_token) {
                        window.myRefreshToken = data.refresh_token;
                        console.log('\n===================================================================');
                        console.log('SUCCESS! Got fresh refresh token!');
                        console.log('Token:', window.myRefreshToken);
                        console.log('Length:', window.myRefreshToken.length);
                        console.log('Saved to: window.myRefreshToken');
                        console.log('===================================================================');
                        console.log('\nNEXT STEP: Run jwt_refresh_ULTRA_CLEAN.js');
                        
                        // Restore original fetch
                        window.fetch = originalFetch;
                    } else {
                        console.log('WARNING: No refresh_token in response');
                        console.log('Available fields:', Object.keys(data));
                    }
                }).catch(e => {
                    console.log('Could not parse response as JSON:', e.message);
                });
            }
            
            return response;
        });
    };
    
    // Step 3: Click the button
    console.log('\n[Step 3] Clicking Checkout button...');
    checkoutButton.click();
    console.log('Button clicked! Waiting for response...');
    
    // Timeout after 5 seconds
    setTimeout(() => {
        if (!window.myRefreshToken || window.myRefreshToken.length < 50) {
            console.log('\n===================================================================');
            console.log('TIMEOUT: No refresh token captured');
            console.log('===================================================================');
            console.log('MANUAL METHOD:');
            console.log('1. Open DevTools Network tab (F12)');
            console.log('2. Click Checkout button');
            console.log('3. Find /JWT/refresh/checkout request');
            console.log('4. Look at Response tab');
            console.log('5. Copy the refresh_token value');
            console.log('6. Run: window.myRefreshToken = "PASTE_HERE"');
            window.fetch = originalFetch; // Restore
        }
    }, 5000);
    
})();
