# Continue CLI — Security Check

Rate all code changes on security. Flag any of the following:

## Hard Blocks (fail PR)
- API keys, tokens, passwords, or secrets hardcoded in code
- SQL string concatenation without parameterization (SQL injection)
- Unsanitized user input rendered in HTML (XSS)
- `eval()` or `Function()` with user-controlled input
- Path traversal vulnerabilities (user-controlled file paths without sanitization)
- SSRF vulnerabilities (user-controlled URLs fetched server-side without validation)
- Disabled TLS/SSL verification
- MD5 or SHA1 for password hashing (must use bcrypt/argon2)

## Warnings (note in review)
- Missing rate limiting on public endpoints
- Overly permissive CORS configuration
- Missing authentication on sensitive endpoints
- Sensitive data logged to console
- Dependency with known vulnerability (check npm audit / pip-audit)
- Missing Content-Security-Policy headers

## Voice AI Specific
- User-uploaded audio not validated for file type/size
- Voice clone samples not scoped to the org that uploaded them
- API keys from user config not encrypted before storage
- Call recordings accessible without authentication
- SIP credentials stored in plaintext

## Output Format
Rate security: [1-10]
Issues found: [list]
Recommendation: [PASS / FAIL / WARN]
