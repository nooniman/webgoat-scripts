// Check Form Field Names
// This will show what the actual form on the page is using

(function() {
    console.log('===================================================================');
    console.log('CHECKING FORM FIELD NAMES');
    console.log('===================================================================');
    
    // Find all forms on the page
    const forms = document.querySelectorAll('form');
    console.log('Found ' + forms.length + ' forms on page\n');
    
    forms.forEach((form, index) => {
        console.log('[Form ' + (index + 1) + ']');
        console.log('Action: ' + form.action);
        console.log('Method: ' + form.method);
        console.log('Fields:');
        
        const inputs = form.querySelectorAll('input, select, textarea');
        inputs.forEach(input => {
            console.log('  - Name: "' + input.name + '" | Type: ' + input.type + ' | ID: ' + input.id);
        });
        console.log('');
    });
    
    console.log('===================================================================');
    console.log('TIP: The "name" attribute is what gets sent in the POST request');
    console.log('===================================================================');
})();
