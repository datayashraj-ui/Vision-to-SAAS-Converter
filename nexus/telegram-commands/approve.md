# /approve — Approve a Pending Decision

**Trigger:** founder says "approve", "I approve", "yes", "go ahead", "do it", "yes go for it"
Also handles: "reject", "no", "don't", "cancel", "abort"

## What to Do

1. Check pending approval queue in Cognee/Beads
2. If exactly one pending item: approve it immediately
3. If multiple pending items: ask which one
4. If no pending items: confirm and suggest checking /tasks

## Approve Response
```
✅ Approved! Executing: [what was approved]

[Immediately starts the task]

I'll update you when it's done.
```

## Reject Response
When founder says "reject", "no", "don't":
```
Got it, cancelled: [what was rejected]

[If there's an obvious alternative]: Should I try [alternative approach] instead?
[If no alternative]: Noted. I'll leave this for now — just say 'build [X]' when you're ready.
```

## Multiple Pending Items
```
I have [X] things waiting for your approval:

1. [Decision 1] — [brief context]
2. [Decision 2] — [brief context]
3. [Decision 3] — [brief context]

Reply with the number to approve, or 'approve all' to approve everything.
```

## Context for Approvals
Before sending any approval request, CEO must include:
- What it is (1 sentence)
- Why it needs approval (confidence < 50%)
- Recommendation
- What happens if rejected (alternative)
- Time sensitive? (yes/no)
