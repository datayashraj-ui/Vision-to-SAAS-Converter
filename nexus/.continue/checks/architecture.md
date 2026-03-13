# Continue CLI — Architecture Check

Evaluate code changes against VoiceForge architecture principles.

## Architecture Principles
1. All IDs must be UUIDs (not sequential integers)
2. All database queries must include `org_id` filter (multi-tenant isolation)
3. All external service calls must go through service layer (not directly in routes)
4. All sensitive config (API keys) must be read from environment variables
5. All Docker images must be ARM64 compatible
6. No direct database queries in React components (must go through tRPC)
7. All audio files must stream — never load full audio into memory
8. All real-time features must use WebSocket (not polling)

## Flag These
- Direct `fetch()` calls to external services from UI components
- Database queries in Next.js page components (should be in tRPC routers)
- Hardcoded URLs or environment-specific values
- Non-streaming audio handling (loading full WAV into memory)
- Missing `org_id` scope in database queries
- New dependencies that aren't ARM64 compatible
- New paid SaaS dependencies (must check cost against $100/mo budget)

## Multi-Tenancy Check
For every new database query or mutation:
- Does it filter by `org_id`? ✓
- Does it prevent one org from accessing another org's data? ✓
- Does it check plan limits before allowing the operation? ✓

## Output Format
Rate architecture adherence: [1-10]
Issues found: [list]
Recommendation: [PASS / FAIL / WARN]
