# /build — Start Building Something

**Trigger:** founder says "build [X]", "create [X]", "make [X]", "add feature [X]", "I want [X]"

## What to Do

1. **Extract intent** from founder's message — what exactly does he want built?
2. **Check Cognee** — has something similar been built or attempted before?
3. **Check current sprint** — does this fit in the current sprint or is it backlog?
4. **Create SpecKit spec** — write a concise spec to `products/voice-ai-saas/specs/[feature-name].md`
5. **Break into Beads tasks** — create 2–5 specific, actionable tasks
6. **Assign to CTO** — send task IDs via Agent Mail to CTO agent
7. **Respond to founder** — confirm you've started it

## SpecKit Spec Template
```markdown
# Feature: [Name]
**Requested by:** Yash via Telegram
**Date:** [date]
**Priority:** [P0/P1/P2]

## What It Does
[2-3 sentences — what the user sees and does]

## Why We're Building It
[1-2 sentences — business reason]

## Acceptance Criteria
- [ ] [specific, testable requirement]
- [ ] [specific, testable requirement]
- [ ] [specific, testable requirement]

## Technical Notes
[Brief technical considerations for CTO]

## Out of Scope
[What we're NOT building to keep this focused]
```

## Response Format
```
Got it! Building: [concise description of what you understood]

I've created the spec and assigned [X] tasks to CTO.

ETA: [realistic estimate based on task complexity]
[If this sprint: "CTO will start after finishing [current task]"]
[If next sprint: "This goes into next sprint — current sprint ends [date]"]

I'll update you at [midday/evening] check-in. Or say 'tasks' to see the queue anytime.
```

## Clarification Protocol
If the request is ambiguous, ask ONE clarifying question before building:
```
Quick question before I spec this out:
[The one most important clarifying question]

(Or just say 'figure it out' and I'll make a reasonable call)
```

## If Request Conflicts with Current Work
```
Heads up: CTO is currently working on [X] (estimated [Y] more hours).

I can:
1. Queue this for after — it'll start [estimated date]
2. Interrupt current work and prioritize this instead

What do you prefer?
```
