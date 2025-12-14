// Security Questions - Find Correct Endpoint
// Run this in browser console to discover the right endpoint

(async function() {
    console.log('===================================================================');
    console.log('FINDING CORRECT ENDPOINT FOR SECURITY QUESTIONS');
    console.log('===================================================================');
    
    // Possible endpoints to try
    const endpoints = [
        '/WebGoat/questions/question',
        '/WebGoat/PasswordReset/SecurityQuestions',
        '/WebGoat/PasswordReset/ForgotPassword/SecurityQuestions',
        '/WebGoat/PasswordReset/security-question',
        '/WebGoat/securityQuestions',
        '/WebGoat/reset/password'
    ];
    
    console.log('\n[Step 1] Testing endpoints...\n');
    
    for (const endpoint of endpoints) {
        console.log('Testing: ' + endpoint);
        
        try {
            const response = await fetch(endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    username: 'webgoat',
                    securityQuestion: 'red'
                })
            });
            
            console.log('  Status: ' + response.status);
            console.log('  Content-Type: ' + response.headers.get('content-type'));
            
            if (response.headers.get('content-type').includes('json')) {
                const data = await response.json();
                console.log('  Response: ' + JSON.stringify(data, null, 2));
                
                if (response.status === 200 || data.feedback || data.lessonCompleted !== undefined) {
                    console.log('  [FOUND] This looks like the correct endpoint!');
                }
            }
            
            console.log('');
            
        } catch (error) {
            console.log('  Error: ' + error.message);
            console.log('');
        }
        
        await new Promise(resolve => setTimeout(resolve, 500));
    }
    
    console.log('===================================================================');
    console.log('[Step 2] Check Network tab for actual endpoint');
    console.log('===================================================================');
    console.log('1. Keep DevTools Network tab open');
    console.log('2. Fill out the form on the page manually');
    console.log('3. Click Submit');
    console.log('4. Look for the POST request in Network tab');
    console.log('5. That is the correct endpoint to use!');
    console.log('===================================================================');
})();
