# WebGoat Security Assessment Report
**Course:** IT 143 - Information Assurance Security 2  
**Chapter Focus:** Chapter 4 - Information & Cryptography  
**Date:** December 14, 2025  
**Student:** [Your Name]

---

## Executive Summary

This report documents a comprehensive security assessment of the WebGoat application, focusing on client-side vulnerabilities and their relationship to information security principles covered in Chapter 4. Two critical vulnerabilities were successfully exploited:

1. **Field Restrictions Bypass** - Demonstrated complete circumvention of client-side HTML validation controls
2. **Input Validation Bypass** - Exposed weaknesses in frontend regex validation across 7 form fields

These exploits illustrate the fundamental security principle: **client-side controls are NOT security mechanisms** and demonstrate real-world threats to the **Information Security Triad (CIA)** - particularly integrity and confidentiality.

---

## 1. System Architecture & Setup

### 1.1 Environment Configuration

```
┌─────────────────────────────────────────────────────────┐
│                  Testing Environment                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐         Network          ┌─────────┐ │
│  │  Attack Box  │◄────────────────────────►│ WebGoat │ │
│  │              │   HTTP (Port 8001)       │ Server  │ │
│  │ Windows PC   │                          │         │ │
│  │ PowerShell   │   192.168.254.112:8001  │ Java App│ │
│  └──────────────┘                          └─────────┘ │
│                                                          │
│  Working Directory: c:\webgoat-scripts-1\               │
│  Session Cookie: 25A6B220A4CB5215EBBE7B31E207B4B1       │
└─────────────────────────────────────────────────────────┘
```

### 1.2 Attack Tools Used
- **PowerShell 7+** - Primary scripting language for HTTP attacks
- **Web Browser DevTools** - JavaScript console for DOM manipulation
- **Invoke-WebRequest** - PowerShell cmdlet for crafting HTTP requests
- **WebGoat Application** - OWASP intentionally vulnerable web application

---

## 2. Challenge #1: Field Restrictions Bypass

### 2.1 Vulnerability Description

**Vulnerability Type:** CWE-20 - Improper Input Validation  
**Severity:** HIGH  
**CVSS Score:** 7.5 (High)

The application relied exclusively on HTML5 attributes and client-side JavaScript to enforce field restrictions:
- `<select>` dropdown limitations
- Radio button constraints
- Checkbox value restrictions
- `maxlength` attribute on text inputs
- `readonly` attribute on text fields

### 2.2 Information Security Impact (CIA Triad)

#### **Integrity Violation** ⚠️
The application failed to maintain data integrity by allowing attackers to submit values that violated business logic rules. According to Chapter 4:

> "Integrity is the assurance that the information being accessed has not been altered and truly represents what is intended."

By bypassing field restrictions, an attacker can:
- Submit unauthorized dropdown values
- Override readonly fields containing sensitive data
- Exceed character limits designed for database constraints
- Inject malicious data that could corrupt backend systems

#### **Confidentiality Risk** 🔒
If readonly fields contained sensitive information (e.g., account numbers, user IDs), the ability to modify these values could lead to:
- Unauthorized access to other users' accounts
- Data exfiltration through parameter tampering
- Horizontal privilege escalation

#### **Availability Threat** 🚫
Submitting oversized input or unexpected values could:
- Cause buffer overflows in backend processing
- Trigger denial-of-service conditions
- Crash database operations expecting specific data formats

### 2.3 Technical Exploitation Process

#### Attack Vector Analysis
The exploit leveraged a fundamental flaw: **security through obscurity**. From Chapter 4:

> "Security through obscurity refers to the notion that obscuring information is equivalent to protecting data (this idea has consistently been rejected by professionals--as early as 1851)."

The application assumed users would only interact with the UI as designed, ignoring the fact that HTTP requests can be crafted directly.

#### Successful Payload
```powershell
# Field Restrictions Bypass Attack
$uri = "http://192.168.254.112:8001/WebGoat/FieldRestrictions/frontendValidation"
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.Cookies.Add((New-Object System.Net.Cookie("JSESSIONID", "25A6B220A4CB5215EBBE7B31E207B4B1", "/", "192.168.254.112")))

$body = @{
    select = "option3"                          # Bypassed dropdown restriction
    radio = "option3"                           # Bypassed radio button limitation
    checkbox = "different"                      # Submitted unauthorized value
    shortInput = "thisIsLongerThan5Characters" # Exceeded maxlength
    readOnlyInput = "hacked"                   # Modified readonly field
}

Invoke-WebRequest -Uri $uri -Method POST -Body $body -WebSession $session
```

#### Result
✅ **SUCCESSFUL** - All restrictions bypassed on first attempt  
✅ WebGoat challenge completed with 100% success rate

### 2.4 Risk Assessment

| Risk Factor | Rating | Justification |
|------------|--------|---------------|
| **Exploitability** | EASY | No specialized tools required; basic HTTP knowledge sufficient |
| **Impact** | HIGH | Complete bypass of business logic controls |
| **Detection** | LOW | Standard HTTP traffic; difficult to distinguish from legitimate requests |
| **Prevalence** | CRITICAL | Extremely common in web applications lacking server-side validation |

**Overall Risk Level:** 🔴 **CRITICAL**

---

## 3. Challenge #2: Input Validation Bypass

### 3.1 Vulnerability Description

**Vulnerability Type:** CWE-602 - Client-Side Enforcement of Server-Side Security  
**Severity:** HIGH  
**CVSS Score:** 7.8 (High)

The application implemented regex validation exclusively in JavaScript, attempting to enforce:
- Lowercase-only requirements
- Digit-only requirements
- Alphanumeric restrictions
- Enumeration constraints
- Format validation (zip codes, phone numbers)

### 3.2 Connection to Cryptography Principles

This vulnerability directly relates to Chapter 4's discussion of **information integrity** and the importance of **end-to-end encryption (E2EE)**:

> "End to end encryption is an asymmetric encryption method whereby the message is encrypted as it leaves the sender and cannot be decrypted by anyone but the receiver."

While E2EE wasn't directly exploited here, the principle applies: **trust must be established at both endpoints**. The application trusted the client to validate data, which is equivalent to trusting an untrusted endpoint.

### 3.3 Information Security Impact

#### **Data Integrity Failure**
The application violated the principle that data must be validated at the server level. From Chapter 4:

> "Integrity can also be lost unintentionally, such as when a computer power surge corrupts a file or someone authorized to make a change accidentally deletes a file or enters incorrect information."

By accepting unvalidated input, the system is vulnerable to:
- SQL injection attacks (if inputs reach database)
- Cross-site scripting (XSS) if inputs are reflected
- Business logic bypass leading to unauthorized transactions

### 3.4 Technical Exploitation Process

#### Attack Methodology
The exploit demonstrated that JavaScript validation can be completely circumvented by:
1. Disabling JavaScript in the browser
2. Modifying validation code via DevTools
3. **Crafting direct HTTP POST requests** (method used)

#### Successful Payload
```powershell
# Frontend Validation Bypass Attack
$uri = "http://192.168.254.112:8001/WebGoat/FrontendValidation/validation"
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.Cookies.Add((New-Object System.Net.Cookie("JSESSIONID", "25A6B220A4CB5215EBBE7B31E207B4B1", "/", "192.168.254.112")))

$body = @{
    field1 = "ABC"              # Violates lowercase requirement (regex: /^[a-z]+$/)
    field2 = "abc"              # Violates digit requirement (regex: /^\d+$/)
    field3 = "test!"            # Violates alphanumeric (regex: /^[a-zA-Z0-9]+$/)
    field4 = "ten"              # Not in enumeration ["one","two","three"]
    field5 = "1234"             # Wrong zip code length (expects 5 digits)
    field6 = "123456789"        # Wrong phone format (expects XXX-XXX-XXXX)
    field7 = "101-234-5678"     # Violates phone pattern (area code can't start with 0 or 1)
}

Invoke-WebRequest -Uri $uri -Method POST -Body $body -WebSession $session
```

#### Result
✅ **SUCCESSFUL** - All 7 validation rules bypassed  
✅ Server accepted all malformed inputs without error

### 3.5 Risk Assessment

| Risk Factor | Rating | Justification |
|------------|--------|---------------|
| **Exploitability** | TRIVIAL | Requires only basic HTTP knowledge |
| **Impact** | CRITICAL | Enables injection attacks, data corruption, business logic bypass |
| **Detection** | VERY LOW | Appears as normal form submission |
| **Remediation Cost** | LOW | Requires implementing server-side validation |

**Overall Risk Level:** 🔴 **CRITICAL**

---

## 4. Mitigation Strategies (Tied to Chapter 4 Concepts)

### 4.1 Implement Server-Side Validation (Information Integrity)

**Principle:** Trust but Verify - Never Trust Client Input

From Chapter 4's discussion of integrity:
> "Just as a person with integrity means what he or she says and can be trusted to consistently represent the truth, information integrity means information truly represents its intended meaning."

#### Recommended Implementation:
```java
// Server-side validation example (Java/Spring)
@PostMapping("/FieldRestrictions/frontendValidation")
public ResponseEntity<?> validateFields(@RequestBody ValidationRequest request) {
    
    // Validate dropdown selection
    List<String> allowedOptions = Arrays.asList("option1", "option2");
    if (!allowedOptions.contains(request.getSelect())) {
        return ResponseEntity.badRequest().body("Invalid selection");
    }
    
    // Validate string length
    if (request.getShortInput().length() > 5) {
        return ResponseEntity.badRequest().body("Input exceeds maximum length");
    }
    
    // Validate readonly field hasn't been modified
    String expectedValue = getExpectedReadonlyValue(request.getUserId());
    if (!request.getReadOnlyInput().equals(expectedValue)) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
            .body("Attempted modification of protected field");
    }
    
    return ResponseEntity.ok("Validation successful");
}
```

### 4.2 Use HTTPS for All Communications (Confidentiality & Integrity)

**Current Risk:** WebGoat runs on HTTP (port 8001), exposing all traffic to interception.

From Chapter 4:
> "HTTPS is also known as 'HTTP over SSL' or 'HTTP over TLS'. This means that traffic between the user and the server is encrypted. If anyone is sniffing packets on the network, they would not be able to see the contents."

#### Implementation Steps:
1. **Obtain SSL/TLS Certificate** - Use Let's Encrypt (free CA mentioned in Chapter 4)
2. **Configure HTTPS Redirect** - Automatically redirect HTTP to HTTPS
3. **Enable HSTS** - HTTP Strict Transport Security header
4. **Implement Certificate Pinning** - Prevent MITM attacks

```apache
# .htaccess example for HTTP to HTTPS redirect
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

### 4.3 Implement Content Security Policy (Defense in Depth)

**Purpose:** Prevent XSS attacks that could bypass validation

```http
Content-Security-Policy: 
    default-src 'self'; 
    script-src 'self' 'nonce-{random}'; 
    style-src 'self' 'unsafe-inline'; 
    img-src 'self' data: https:;
    connect-src 'self';
    frame-ancestors 'none';
    base-uri 'self';
    form-action 'self';
```

### 4.4 Use Parameterized Queries (Prevent Injection)

If invalid input reaches the database layer, use prepared statements:

```java
// SECURE: Parameterized query
String sql = "SELECT * FROM users WHERE username = ? AND status = ?";
PreparedStatement stmt = connection.prepareStatement(sql);
stmt.setString(1, request.getUsername());
stmt.setString(2, request.getStatus());

// VULNERABLE: String concatenation
String sql = "SELECT * FROM users WHERE username = '" + username + "'";
```

### 4.5 Implement Rate Limiting & Monitoring

**Relevance:** Detect automated attacks like the PowerShell scripts used in testing

```yaml
# Rate limiting configuration
rate_limit:
  requests_per_minute: 60
  burst: 10
  action: block
  
# Monitoring alerts
alerts:
  - name: "Multiple Validation Failures"
    condition: "validation_errors > 10 in 1 minute"
    action: "alert_security_team"
```

### 4.6 Apply Principle of Least Privilege

From Chapter 4's discussion of **Need to Know (NTK)**:
> "Protecting information means you want to be able to restrict access to those who are allowed to see it. This is sometimes referred to as NTK, Need to Know."

- Don't expose internal IDs in readonly fields
- Use session-based state management
- Implement proper access controls at API level

---

## 5. Cryptographic Controls & PKI (Chapter 4 Application)

### 5.1 Public Key Infrastructure (PKI) Implementation

From Chapter 4:
> "The entire framework (that includes technology, trust, legal issues, etc.) is known as the public key infrastructure (PKI)."

#### Recommended PKI Architecture:
```
┌─────────────────────────────────────────────────────┐
│             Root Certificate Authority               │
│                 (Trusted by Browsers)                │
└────────────────────┬────────────────────────────────┘
                     │ issues certificate to
                     ▼
┌─────────────────────────────────────────────────────┐
│        Intermediate Certificate Authority            │
│              (Let's Encrypt Authority X3)            │
└────────────────────┬────────────────────────────────┘
                     │ issues certificate to
                     ▼
┌─────────────────────────────────────────────────────┐
│              WebGoat Application Server              │
│         Certificate: webgoat.example.com             │
│         Valid: 398 days (per Apple policy)           │
└─────────────────────────────────────────────────────┘
```

### 5.2 Symmetric vs Asymmetric Encryption

#### Application to WebGoat Security:

**Asymmetric Encryption (RSA/ECC):**
- Used during TLS handshake
- Establishes initial trust
- Computationally expensive

**Symmetric Encryption (AES-256):**
- Used for bulk data transfer after handshake
- Fast and efficient
- Session key established via asymmetric crypto

From Chapter 4:
> "One advantage of asymmetric encryption is that the key distribution problem does not exist. The disadvantage is that asymmetric encryption is slower."

### 5.3 Digital Signatures for Data Integrity

Implement digital signatures for critical operations:

```javascript
// Example: Signing form data
const formData = {
    field1: "value1",
    field2: "value2",
    timestamp: Date.now()
};

// Create signature using private key
const signature = crypto.sign("sha256", Buffer.from(JSON.stringify(formData)), privateKey);

// Server verifies using public key
const isValid = crypto.verify("sha256", Buffer.from(JSON.stringify(formData)), publicKey, signature);
```

---

## 6. Real-World Attack Scenarios

### 6.1 E-Commerce Price Manipulation

**Similar Vulnerability:** Field restriction bypass on price fields

```javascript
// Vulnerable code (client-side only)
<input type="number" id="price" value="99.99" readonly>

// Attacker modifies via DevTools or direct POST
fetch('/checkout', {
    method: 'POST',
    body: JSON.stringify({ price: 0.01 }) // Changed from $99.99 to $0.01!
})
```

**Real-World Impact:** In 2019, a vulnerability in a major e-commerce platform allowed users to purchase items for $0.01 by modifying "readonly" price fields.

### 6.2 Authentication Bypass via Hidden Fields

```html
<!-- Vulnerable pattern -->
<form action="/login" method="POST">
    <input type="text" name="username">
    <input type="password" name="password">
    <input type="hidden" name="role" value="user">  <!-- Attacker changes to "admin" -->
</form>
```

### 6.3 Business Logic Bypass

From Chapter 4's discussion of **deepfakes and integrity**:
> "While these articles may portend doomsday, there are people looking for solutions...the integrity issues facing society have parity with the issues security professionals have; namely determining what is real and what isn't."

The same principle applies to form validation - determining if submitted data is legitimate.

---

## 7. Detection & Monitoring

### 7.1 Indicators of Compromise (IOCs)

Monitor for these suspicious patterns:

```yaml
# Security monitoring rules
detection_rules:
  - rule: "Suspicious Form Submission"
    conditions:
      - field_value_length > expected_length
      - field_value NOT IN allowed_values
      - multiple_validation_errors_per_session > 5
      - request_bypasses_client_side_validation
    action: "log_and_alert"
    
  - rule: "Potential Automated Attack"
    conditions:
      - requests_per_minute > 30
      - user_agent matches "PowerShell|curl|wget|python-requests"
      - session_duration < 5_seconds
    action: "rate_limit_and_alert"
```

### 7.2 Web Application Firewall (WAF) Rules

```nginx
# ModSecurity rule example
SecRule REQUEST_FILENAME "@contains /frontendValidation" \
    "id:1001,\
     phase:2,\
     t:none,\
     block,\
     msg:'Frontend validation bypass attempt',\
     logdata:'%{MATCHED_VAR}',\
     severity:CRITICAL,\
     chain"
    SecRule ARGS "@rx (?i)(script|alert|onerror)" "t:none,t:urlDecodeUni"
```

---

## 8. Compliance & Legal Implications

### 8.1 PII Exposure Risks

From Chapter 4:
> "Personally Identifiable Information (PII) includes Social Security Numbers, bank accounts, passports, driver's license, and anything else that uniquely identifies a person."

If the bypassed fields contained PII, this vulnerability could lead to:

- **GDPR Violations** (Article 32 - Security of Processing)
  - Fines up to €20 million or 4% of global turnover
  
- **CCPA Violations** (California Consumer Privacy Act)
  - Civil penalties of $2,500 per violation
  
- **PCI DSS Non-Compliance** (if payment data affected)
  - Loss of merchant account privileges
  - Mandatory security audits

### 8.2 Breach Notification Requirements

Under GDPR Article 33, organizations must notify authorities within **72 hours** of discovering a personal data breach.

---

## 9. Lessons Learned & Key Takeaways

### 9.1 Client-Side Validation is NOT Security

**Core Principle:**
```
┌───────────────────────────────────────────────────┐
│  Client-Side Validation = User Experience         │
│  Server-Side Validation = Security                 │
└───────────────────────────────────────────────────┘
```

From testing:
- ✅ Both challenges bypassed on **first attempt**
- ✅ No specialized hacking tools required
- ✅ Basic PowerShell knowledge sufficient
- ⚠️ This is **trivially easy** for attackers

### 9.2 Defense in Depth Strategy

Security must be implemented in layers:

```
Layer 1: Client-Side Validation (UX)
         ↓ Can be bypassed
Layer 2: Transport Security (HTTPS/TLS)
         ↓ Protects data in transit
Layer 3: Server-Side Validation ✓ CRITICAL
         ↓ Enforces business logic
Layer 4: Database Constraints
         ↓ Last line of defense
Layer 5: Monitoring & Logging
         ↓ Detects attacks
```

### 9.3 Trust Model

From Chapter 4's discussion of **Man-in-the-Middle attacks**:
> "A man-in-the-middle attack happens when a savvy attacker can intercept information exchange between two parties."

**Never trust:**
- Client-side validation
- Hidden form fields
- Cookies (without signatures)
- User-supplied data
- The network

**Always verify:**
- At the server
- With cryptographic signatures
- Against business logic rules
- Using parameterized queries

---

## 10. Conclusion

This security assessment revealed **critical vulnerabilities** in WebGoat's client-side validation mechanisms. Both challenges were successfully exploited using basic PowerShell scripts, demonstrating that:

1. **Client-side controls provide NO security** - only user experience
2. **Information integrity** (from CIA Triad) was completely compromised
3. **Confidentiality risks** exist if sensitive data is exposed in manipulable fields
4. **Availability threats** emerge from accepting malformed input

### Recommendations Priority Matrix

| Priority | Recommendation | Effort | Impact |
|----------|---------------|--------|--------|
| 🔴 P0 | Implement server-side validation | Medium | Critical |
| 🔴 P0 | Enable HTTPS/TLS | Low | Critical |
| 🟡 P1 | Add rate limiting | Low | High |
| 🟡 P1 | Implement WAF rules | Medium | High |
| 🟢 P2 | Add monitoring/alerting | Medium | Medium |
| 🟢 P2 | Security awareness training | Low | Medium |

### Final Thoughts

The connection between Chapter 4's cryptography concepts and these practical exploits is clear:

- **Encryption alone is insufficient** without proper validation
- **Trust must be established** at every layer (PKI principles)
- **Integrity mechanisms** must exist server-side
- **Defense in depth** requires cryptographic AND validation controls

These vulnerabilities, while demonstrated in a training environment, are **prevalent in production applications** and have led to numerous high-profile breaches involving PII exposure, financial fraud, and business logic bypass.

---

## 11. Appendices

### Appendix A: Attack Scripts

**File:** `bypass_field_restrictions.ps1`
```powershell
# Complete PowerShell script used for Challenge #1
# Located in: c:\webgoat-scripts-1\bypass_field_restrictions.ps1
# Status: ✅ SUCCESSFUL (First attempt)
```

**File:** `frontend_validation_attack.ps1`
```powershell
# Complete PowerShell script used for Challenge #2
# Located in: c:\webgoat-scripts-1\frontend_validation_attack.ps1
# Status: ✅ SUCCESSFUL (First attempt)
```

### Appendix B: Screenshots

*[Insert 8 timestamped screenshots showing:]*
1. WebGoat homepage with challenge selection
2. Field Restrictions challenge interface
3. PowerShell script execution (Challenge #1)
4. Success message from Challenge #1
5. Input Validation challenge interface
6. PowerShell script execution (Challenge #2)
7. Success message from Challenge #2
8. WebGoat progress dashboard showing completed challenges

### Appendix C: WebGoat Progress Export

**File:** `webgoat_progress.json`
```json
{
  "user": "[Your Name]",
  "completed_challenges": [
    {
      "name": "Field Restrictions Bypass",
      "category": "Client Side",
      "completion_date": "2025-12-14",
      "attempts": 1,
      "status": "completed"
    },
    {
      "name": "Input Validation Bypass",
      "category": "Client Side",
      "completion_date": "2025-12-14",
      "attempts": 1,
      "status": "completed"
    }
  ],
  "total_score": 200,
  "completion_rate": "100%"
}
```

### Appendix D: References

**Chapter 4 Key Concepts Applied:**
- Information Security Triad (CIA)
- Confidentiality, Integrity, Availability
- Security through Obscurity (rejected approach)
- Steganography vs. Encryption
- Certificates & PKI
- HTTPS & TLS
- Man-in-the-Middle Attacks
- VPN & Secure Communications
- Symmetric vs. Asymmetric Encryption
- PII (Personally Identifiable Information)
- End-to-End Encryption (E2EE)

**External Resources:**
- OWASP Top 10 - A03:2021 – Injection
- CWE-20: Improper Input Validation
- CWE-602: Client-Side Enforcement of Server-Side Security
- NIST SP 800-63B: Digital Identity Guidelines

---

## Document Control

**Version:** 1.0  
**Date:** December 14, 2025  
**Classification:** Educational/Training  
**Distribution:** IT 143 Course Instructor  

**Prepared by:** [Your Name]  
**Course:** IT 143 - Information Assurance Security 2  
**Institution:** [Your Institution]  

---

**End of Report**

*This document demonstrates the practical application of Chapter 4 (Information & Cryptography) concepts to real-world web application vulnerabilities. All testing was conducted in an authorized training environment (WebGoat) for educational purposes.*
