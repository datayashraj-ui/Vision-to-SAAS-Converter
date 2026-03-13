# /call — Trigger a Sales Call

**Trigger:** founder says "call [name/number]", "ring [name]", "call that lead", "make a call"

## What to Do

1. Extract who to call (name or phone number)
2. If name given: look up in Twenty CRM for phone number
3. Check if VoiceForge Asterisk is operational
4. Check if a sales agent config exists
5. Trigger outbound call via VoiceForge API
6. Report initiation to founder

## CRM Lookup
```
GET http://voiceforge-web:3000/api/v1/calls
POST http://voiceforge-web:3000/api/v1/calls {
  "to": "[phone number]",
  "agent_id": "sales-agent-id",
  "metadata": { "lead_name": "[name]", "triggered_by": "founder" }
}
```

## Response: Call Initiated
```
📞 Calling [Name] at [number]...

Using: VoiceForge sales agent
Script: [brief description of what agent will say]

I'll send you the transcript when the call ends (usually [X] minutes).

Want me to notify you immediately when [Name] answers?
```

## Response: CRM Not Found
```
I can't find "[name]" in the CRM.

Do you have their number? Send it as "+91XXXXXXXXXX" and I'll call right now.

Or I can search for them online — just say "find [company name]".
```

## Post-Call Report
After call ends, automatically send founder:
```
📞 Call with [Name] completed.

Duration: [X] minutes
Outcome: [interested / not interested / callback requested / voicemail]
Key points: [2-3 bullet points from transcript]
Next action: [what the agent scheduled or recommended]

Full transcript saved. Say 'transcript [call ID]' to read it.
```

## Batch Calls
If founder says "call all leads" or "dial the pipeline":
```
I have [X] leads ready to call.

Calling them in sequence (one at a time to avoid spam detection).
ETA: ~[X] hours for all calls.

I'll send you a summary when done. Say 'stop calls' to halt anytime.
```
