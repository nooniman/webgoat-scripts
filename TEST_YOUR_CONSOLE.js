// ═══════════════════════════════════════════════════════════
// SUPER SIMPLE TEST - PASTE THIS FIRST TO TEST YOUR CONSOLE
// ═══════════════════════════════════════════════════════════

// TEST 1: Can your console run JavaScript?
(function() {
    console.log('═══════════════════════════════════════');
    console.log('TEST 1: Console Check');
    console.log('═══════════════════════════════════════');
    console.log('%c✅ YOUR CONSOLE IS WORKING!', 'color: white; background: green; font-size: 16px; font-weight: bold; padding: 10px');
    console.log('\nIf you see this message in green, your console works fine.');
    console.log('Now try TEST 2 below.');
})();

// ═══════════════════════════════════════════════════════════
// TEST 2: Can you set variables?
// ═══════════════════════════════════════════════════════════

(function() {
    console.log('\n═══════════════════════════════════════');
    console.log('TEST 2: Variable Check');
    console.log('═══════════════════════════════════════');
    window.testVariable = 'This is a test';
    console.log('✓ Set window.testVariable = "This is a test"');
    console.log('✓ Value:', window.testVariable);
    console.log('%c✅ VARIABLES WORK!', 'color: white; background: green; font-size: 16px; font-weight: bold; padding: 10px');
    console.log('\nNow try TEST 3 below.');
})();

// ═══════════════════════════════════════════════════════════
// TEST 3: Can you make fetch requests?
// ═══════════════════════════════════════════════════════════

(function() {
    console.log('\n═══════════════════════════════════════');
    console.log('TEST 3: Fetch Check');
    console.log('═══════════════════════════════════════');
    console.log('Making a test request...');
    
    fetch('/WebGoat/JWT/refresh/login', {
        method: 'OPTIONS'  // Just check if endpoint exists
    })
    .then(response => {
        console.log('✓ Fetch request completed');
        console.log('  Status:', response.status);
        console.log('  URL:', response.url);
        console.log('%c✅ FETCH WORKS!', 'color: white; background: green; font-size: 16px; font-weight: bold; padding: 10px');
        console.log('\n%c🎉 ALL TESTS PASSED!', 'color: gold; font-size: 20px; font-weight: bold');
        console.log('\nYour browser console is working correctly.');
        console.log('You can now use the attack scripts.');
    })
    .catch(error => {
        console.log('%c⚠️ Fetch failed (but this might be normal)', 'color: orange; font-weight: bold');
        console.log('Error:', error.message);
        console.log('\nThis might just mean the endpoint doesn\'t allow OPTIONS.');
        console.log('Try the actual attack scripts anyway.');
    });
})();

// ═══════════════════════════════════════════════════════════
// AFTER RUNNING ALL 3 TESTS:
// ═══════════════════════════════════════════════════════════
/*

If all 3 tests show green ✅ messages, your console is working fine.

Now you're ready to:
1. Use FIND_REFRESH_TOKEN.js to find your refresh token
2. Use jwt_refresh_ULTRA_DEBUG.js for the attack

If ANY test fails, you'll see exactly what's wrong.

*/
