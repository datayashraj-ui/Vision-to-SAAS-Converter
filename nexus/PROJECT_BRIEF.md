# NEXUS — Project Brief

## What Is NEXUS

NEXUS is an autonomous AI software company that builds, sells, and supports B2B SaaS products. It is controlled entirely from a mobile phone via Telegram and WhatsApp. The founder (Yash) provides strategic direction; the AI agent team executes everything else.

## The Founding Principle

A solo founder should be able to run a software company from their phone, while living their life. No terminals. No dashboards. No standups. Just text messages.

## Infrastructure

| Component | Service | Cost |
|---|---|---|
| Compute | Oracle Cloud Free Tier (ARM, 4 OCPUs, 24GB RAM, 200GB storage) | $0 |
| AI orchestration | OpenClaw + ZeroClaw | Free |
| Agent brain (coding) | Claude Max ($100/mo) | $100/mo |
| Agent brains (ops) | Gemini/Groq/Ollama | $0 |
| Database + Auth | InsForge (self-hosted) | $0 |
| Deployment | Coolify (self-hosted) | $0 |
| Monitoring | GlitchTip + Langfuse + PostHog (self-hosted) | $0 |
| CRM | Twenty CRM (self-hosted) | $0 |
| Support | Chatwoot (self-hosted) | $0 |
| Search | Perplexica (self-hosted) | $0 |
| Memory | Cognee (self-hosted) | $0 |
| Remote access | Tailscale | Free tier |

**Total monthly cost: $100**

## First Product

**Voice AI SaaS for B2B Sales Teams** — See `products/voice-ai-saas/SPEC.md`

## Founder's Daily Experience

1. Wake up. Read morning briefing on Telegram.
2. Reply to any decisions that need approval.
3. Live life.
4. Read midday update.
5. Read evening summary.
6. Occasionally text "build X" or "ship it" or "how much money?"

The company runs itself.

## Success Metrics (Month 1)

- [ ] First paying customer
- [ ] $99 MRR
- [ ] Voice AI MVP deployed
- [ ] All 9 agents running autonomously
- [ ] Zero manual server interventions

## Success Metrics (Month 6)

- [ ] $10K MRR
- [ ] 50+ active customers
- [ ] Second product launched
- [ ] Customer support fully automated via WhatsApp
- [ ] Sales pipeline generating $2K/mo in new MRR

## The Stack

```
Phone (Android)
  └── Telegram ←→ OpenClaw CEO Agent
                        ├── CTO Agent (Claude Code Max, WSL2)
                        ├── Sales Agent (ZeroClaw + PersonaPlex)
                        ├── Support Agent (ZeroClaw + Chatwoot)
                        ├── Marketing Agent (ZeroClaw + Postiz)
                        ├── Finance Agent (ZeroClaw + Stripe)
                        ├── Legal Agent (ZeroClaw)
                        ├── Product Analyst (ZeroClaw + PostHog)
                        ├── Market Scout (ZeroClaw + Perplexica)
                        └── Watchdog (ZeroClaw + GlitchTip)

All running on: Oracle Cloud ARM (free tier)
All deployed via: Coolify
All monitored via: GlitchTip + Langfuse
```
