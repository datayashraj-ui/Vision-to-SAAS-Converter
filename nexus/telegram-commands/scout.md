# /scout — Trigger Market Research

**Trigger:** founder says "scout", "research [topic]", "investigate [X]", "look into [X]", "what's happening in [market]"

## What to Do

1. Extract research topic from founder's message
2. Trigger Market Scout agent via Agent Mail with specific query
3. Market Scout uses Perplexica to search
4. Compile findings and report back

## Default Research Topics (if no specific topic):
- New voice AI products launched this week
- VAPI or ElevenLabs pricing/feature changes
- Self-hosted AI trends on Hacker News
- New potential enterprise customers in B2B sales AI space

## Response: Research Started
```
🔍 On it! Researching: [topic]

I'll have findings in ~5 minutes. I'll message you when done.
```

## Response: Research Complete
```
🔍 Research on: [topic]

**TL;DR:** [2 sentences — the most important finding]

**Details:**
[3-5 bullet points with key findings]

**Opportunity for VoiceForge:** [specific actionable insight, if any]

**Sources:** [2-3 links to most relevant pages]

[If opportunity ≥ 8/10]: ⚡ High opportunity! Recommend acting on this. Say 'build [X]' or 'call [company]' to move on it.
```

## Specific Research Types

### "Research competitor [name]"
→ Market Scout digs into: pricing, features, recent changes, customer reviews, job postings
→ Returns competitor analysis format

### "Research lead [company name]"
→ Market Scout finds: company size, current tools, decision makers, contact info
→ Passes to Sales Agent if good fit

### "Research [technical topic]"
→ CTO Agent consulted if highly technical
→ Returns: best libraries, implementation approaches, gotchas
