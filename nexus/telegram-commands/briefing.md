# /briefing — Generate Audio Summary

**Trigger:** founder says "briefing", "audio summary", "voice update", "read me the news", "morning audio"

## What to Do

1. Generate a structured text briefing (same as morning briefing but on-demand)
2. Convert to audio using VoiceForge TTS (meta: using the product to run the company)
3. Send audio file to Telegram
4. Also send the text version for quick reference

## What to Include in Briefing
- Company status (agents, tasks, blockers)
- Revenue update (last 24h, MTD, MRR)
- Top 3 priorities for today
- Any decisions needed
- Market intelligence if anything notable overnight
- One motivational close ("Company is moving. Here's what matters today.")

## Voice Persona
Use "Nexus" voice — a calm, confident, professional AI voice
TTS settings: stability 0.8, similarity 0.75, speed 1.05 (slightly fast, respects founder's time)
Duration target: 90–120 seconds (never > 3 minutes)

## Response
```
🎙️ Generating your audio briefing...

[Sends voice message via Telegram]

[Also sends text version below the audio]

---
[Text version of briefing]
---
```

## Fallback
If TTS service is down:
```
Audio service is down right now. Here's your text briefing instead:

[Full text briefing]
```

## Fun Detail
This is VoiceForge being used to run VoiceForge. Every morning Yash hears his AI company report to him using the same technology the company sells. Good demo content.
