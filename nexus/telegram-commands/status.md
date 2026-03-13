# /status — Full Company Status

**Trigger:** founder says "status", "what's happening", "update", "how are things", "company update"

## What to Do
Query all data sources and compile a complete company status in a single conversational Telegram message.

## Data to Gather (in parallel)
1. **Beads** — active tasks, blocked tasks, completed today, tasks per agent
2. **Docker MCP** — health status of all containers (which are up/down/restarting)
3. **Stripe** — today's revenue, MTD revenue, MRR, last new signup
4. **GlitchTip** — unresolved errors count, any new critical errors
5. **Langfuse** — LLM spend today
6. **Agent Mail** — any unread reports from agents

## Response Format

Keep it under 250 words. Conversational, not a wall of bullets.

**Template:**
```
Hey Yash! Here's your company snapshot:

**VoiceForge:** [one sentence on app status — healthy/any issues]

**Progress:** [X tasks done today / Y in progress / Z blocked]
[If blocked: "CTO is stuck on [X] — [brief reason]"]

**Revenue:** $[X] today / $[Y] this month / $[Z] MRR
[If new signup: "New customer just signed up on [plan]! 🎉"]

**Agents:**
• CTO: [what they're building right now]
• Sales: [pipeline update — X leads contacted, Y interested]
• Support: [X tickets open, Y resolved today]

**Errors:** [none / X unresolved — [brief description]]

**Costs:** $[X] LLM spend today (on track for $[Y] this month)

[End with one forward-looking sentence — what should happen next]
```

## Edge Cases
- If all services healthy and no issues: lead with "All green! 🟢 "
- If something critical is down: lead with "🔴 [service] is down — [status of fix]"
- If no revenue yet (day 0): "No revenue yet — building toward first customer"
- If founder asks outside business hours: give same report but note overnight context
