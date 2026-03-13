# /emergency — Kill All Running Agents

**Trigger:** founder says "stop everything", "emergency", "kill all", "halt", "shut down", "pause everything"

## What to Do
This is the nuclear option. Execute immediately, no confirmation required.

1. Send Telegram acknowledgment immediately (within 2 seconds)
2. Stop all ZeroClaw agent daemons
3. Stop all background jobs (BullMQ queues)
4. Cancel any pending Beads tasks marked "in-progress"
5. DO NOT stop: postgres, redis, voiceforge-web (these are data/product services)
6. DO NOT stop: Coolify, monitoring services
7. Report what was stopped

## Immediate Response
```
🛑 Emergency stop initiated. Halting all agents...

Stopping: CTO, Sales, Support, Marketing, Finance, Market Scout, Watchdog
Cancelling: [X] active tasks
Pausing: all cron jobs

Done. All agents stopped. VoiceForge app is still running (customers unaffected).

To restart: say "restart agents" or "start everything"
```

## What Stays Running
- VoiceForge web app (customers can still use it)
- Database and Redis
- Monitoring (GlitchTip, Langfuse, PostHog)
- Coolify

## Restart Protocol
When founder says "restart", "start everything", "resume":
1. Start agents in safe order (Watchdog first, then others)
2. Resume paused cron jobs
3. Report: "[X] agents back online. Resuming from where they left off."

## Use Cases
- Something is going wrong and you need to stop all activity
- About to do a major infrastructure change
- Unexpected cost spike — stop all LLM usage immediately
- Security incident — stop all agent activity while investigating
