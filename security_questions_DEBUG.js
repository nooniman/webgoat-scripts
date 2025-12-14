// Security Questions - Debug Version
// This will show ALL responses so we can see what's happening

(async function() {
    console.log('===================================================================');
    console.log('SECURITY QUESTIONS DEBUG - Checking Response Format');
    console.log('===================================================================');
    
    // Test with known good answer first (webgoat/red)
    console.log('\n[Test 1] Testing with webgoat/red (should work)...');
    
    try {
        const response = await fetch('/WebGoat/PasswordReset/questions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                username: 'webgoat',
                securityQuestion: 'red'
            })
        });
        
        const data = await response.json();
        console.log('Response for webgoat/red:');
        console.log(JSON.stringify(data, null, 2));
        console.log('Keys in response:', Object.keys(data));
    } catch (error) {
        console.log('Error:', error.message);
    }
    
    // Test with wrong answer
    console.log('\n[Test 2] Testing with webgoat/blue (should fail)...');
    
    try {
        const response = await fetch('/WebGoat/PasswordReset/questions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                username: 'webgoat',
                securityQuestion: 'blue'
            })
        });
        
        const data = await response.json();
        console.log('Response for webgoat/blue:');
        console.log(JSON.stringify(data, null, 2));
    } catch (error) {
        console.log('Error:', error.message);
    }
    
    // Test with tom
    console.log('\n[Test 3] Testing with tom/red...');
    
    try {
        const response = await fetch('/WebGoat/PasswordReset/questions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                username: 'tom',
                securityQuestion: 'red'
            })
        });
        
        const data = await response.json();
        console.log('Response for tom/red:');
        console.log(JSON.stringify(data, null, 2));
    } catch (error) {
        console.log('Error:', error.message);
    }
    
    console.log('\n===================================================================');
    console.log('Analysis complete! Check responses above to understand format.');
    console.log('===================================================================');
})();
