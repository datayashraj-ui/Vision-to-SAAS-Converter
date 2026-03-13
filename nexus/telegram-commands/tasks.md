# /tasks — Current Task Queue

**Trigger:** founder says "tasks", "show tasks", "what's being worked on", "task queue", "sprint"

## What to Do
Query Beads for current task queue and format a clean status report.

## Response Format
```
📋 Task Queue — [date]

**In Progress:**
• [T-ID] [Task name] — [Agent] — [started X hours ago]
• [T-ID] [Task name] — [Agent] — [started X hours ago]

**Ready / Up Next:**
• [T-ID] [Task name] — [Agent] — [priority]
• [T-ID] [Task name] — [Agent] — [priority]

**Blocked 🔴:**
• [T-ID] [Task name] — [reason] — [waiting X hours]

**Done Today ✅:**
• [T-ID] [Task name] — completed [X hours ago]
• [T-ID] [Task name] — completed [X hours ago]

Sprint [N] progress: [X]/[Y] tasks complete
```

## If Queue is Empty
"All tasks complete! Tell me what to build next."

## If Many Tasks
Show max 5 per section. For "done today" only show last 5.
Add: "([X] more) — say 'full tasks' for complete list"

## Interactive Options
After showing tasks, add:
"You can: say a task ID to get details, 'add task [description]' to add one, or 'prioritize [T-ID]' to move something to the top."
