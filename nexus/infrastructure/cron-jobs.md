# Scheduled Agent Tasks (Cron Jobs)

All cron jobs run via OpenClaw's built-in scheduler. They trigger LLM prompts or agent tasks.

## Schedule Overview

| Time | Job | Agent | Channel |
|---|---|---|---|
| 2:00 AM daily | Jules maintenance | CTO | internal |
| 3:00 AM daily | Market research scan | Market Scout | internal (only alerts if ≥8/10) |
| 7:00 AM daily | Morning briefing | CEO | Telegram |
| 9:00 AM daily | Finance daily report | Finance | internal → CEO |
| 9:00 AM daily | Sales prospecting | Sales | internal |
| 12:00 PM daily | Midday update | CEO | Telegram |
| 6:00 PM daily | Evening summary | CEO | Telegram |
| 6:00 PM daily | Support daily digest | Support | internal → CEO |
| Every 15 min | Agent health check | Watchdog | internal |
| Monday 9:00 AM | Product analytics weekly | Product Analyst | internal → CEO |
| Monday 10:00 AM | Competitive intelligence | Market Scout | internal → CEO |
| 1st of month | Monthly finance report | Finance | Telegram |
| Sunday 10:00 AM | Weekly company review | CEO | Telegram |

## OpenClaw Cron Syntax
Standard cron syntax: `MINUTE HOUR DAY-OF-MONTH MONTH DAY-OF-WEEK`
Examples:
- `0 7 * * *` = Every day at 7:00 AM
- `0 9 * * MON` = Every Monday at 9:00 AM
- `*/15 * * * *` = Every 15 minutes
- `0 0 1 * *` = First of every month at midnight

## Adding New Cron Jobs
Edit `infrastructure/openclaw-config.json5` → `"cron"` array.
Each job needs: `name`, `schedule`, `channel`, `prompt`.
Restart OpenClaw: `docker restart openclaw-ceo`

## Emergency Stop
To pause all cron jobs: `docker exec openclaw-ceo openclaw cron pause`
To resume: `docker exec openclaw-ceo openclaw cron resume`
