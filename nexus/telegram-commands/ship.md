# /ship — Deploy to Production

**Trigger:** founder says "ship", "deploy", "launch", "push to prod", "go live", "ship it"

## What to Do

1. **Check what's ready** — query Beads for tasks marked "ready to deploy"
2. **Run pre-deploy checks** (in parallel):
   - Continue CLI review on latest code changes
   - Semgrep static analysis (security + quality)
   - TruffleHog secrets scan on git diff
   - Trivy Docker image vulnerability scan
   - Run test suite (Vitest unit tests)
3. **If ALL checks pass:** trigger Coolify deployment
4. **If ANY check fails:** report what failed and ask for decision
5. **Post-deploy:** verify health endpoint, report success

## Pre-Deploy Check Results

**All pass:**
```
✅ All checks passed! Deploying VoiceForge v[version]...

[30 seconds later]

🚀 Shipped! VoiceForge v[version] is live.
URL: https://app.voiceforge.ai
Deploy time: [X] seconds
[X] changes deployed: [brief description]

No issues detected. Let me know if you want me to check anything specific.
```

**Check failed:**
```
🛑 Blocked on deployment — [check name] found issues:

[Brief, plain-English description of the issue]

Options:
1. Fix it (I'll assign to CTO — ~[estimate])
2. Skip this check (not recommended for [specific reason])
3. Revert to [last known good version]

What do you want to do?
```

## Checks Detail

### Continue CLI Review
Run: `continue review --changed-only --output json`
Flag: any files rated < 7/10 quality

### Semgrep Security Scan
Run: `semgrep --config auto --json`
Flag: any HIGH or CRITICAL findings only (ignore LOW/MEDIUM)

### TruffleHog Secrets Scan
Run: `trufflehog git --since-commit HEAD~5 --json`
Flag: ANY detected secrets (this is a hard block — never skip)

### Trivy Image Scan
Run: `trivy image --severity HIGH,CRITICAL voiceforge:latest`
Flag: CRITICAL vulnerabilities only (HIGH → warn, don't block)

### Test Suite
Run: `bun test` or `npm test`
Flag: any failing tests

## Rollback Protocol
If deployment succeeds but monitoring shows errors spike > 50% within 10 minutes:
```
🔴 Rollback triggered: error rate spiked to [X]% after deployment.
Rolling back to v[previous version]...
[30 seconds later]
✓ Rolled back. System stable. CTO will investigate.
```
