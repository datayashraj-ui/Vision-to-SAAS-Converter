# NEXUS — Your Autonomous AI Company

> Build software. Sell it. Support customers. All from Telegram.

NEXUS is an autonomous AI company controlled entirely from a mobile phone. The founder (Yash) texts commands on Telegram. The AI team of 10 agents builds products, closes customers, handles support, and grows revenue — while he lives his life.

**First product: [VoiceForge](./products/voice-ai-saas/SPEC.md)** — a self-hosted alternative to ElevenLabs + VAPI + Asterisk combined. One platform, zero per-minute fees, real phone calls.

---

## What's Been Built

```
nexus/
├── CLAUDE.md                        ✅ CEO Agent brain
├── PROJECT_BRIEF.md                 ✅ Company overview
├── agents/
│   ├── ceo.md                       ✅ CEO (OpenClaw, Telegram-first)
│   ├── cto.md                       ✅ CTO (Claude Code Max)
│   ├── sales.md                     ✅ Sales (ZeroClaw + PersonaPlex)
│   ├── marketing.md                 ✅ Marketing (ZeroClaw + Postiz)
│   ├── support.md                   ✅ Support (ZeroClaw + Chatwoot)
│   ├── finance.md                   ✅ Finance (ZeroClaw + Stripe)
│   ├── legal.md                     ✅ Legal (ZeroClaw)
│   ├── product-analyst.md           ✅ Product Analyst (ZeroClaw + PostHog)
│   ├── market-scout.md              ✅ Market Scout (ZeroClaw + Perplexica)
│   └── watchdog.md                  ✅ Watchdog (ZeroClaw + GlitchTip)
├── products/voice-ai-saas/
│   ├── SPEC.md                      ✅ Full product spec (ElevenLabs+VAPI+Asterisk)
│   ├── PLAN.md                      ✅ 8-week phased build plan (5 phases, 68 tasks)
│   └── TASKS.md                     ✅ Sprint task queue
├── infrastructure/
│   ├── docker-compose.yml           ✅ Full stack (20+ services, ARM64)
│   ├── openclaw-config.json5        ✅ CEO agent config + cron + Telegram skills
│   └── oracle-cloud-setup.md        (see scripts/setup-oracle.sh)
├── telegram-commands/               ✅ 10 Telegram command skills
├── scripts/
│   ├── setup-oracle.sh              ✅ Full Oracle Cloud install script
│   └── setup-windows.ps1            ✅ Windows WSL2 CTO setup
├── docs/
│   ├── ARCHITECTURE.md              ✅ Technical architecture
│   ├── DECISIONS.md                 ✅ Decision log
│   ├── PROGRESS_LOG.md              ✅ Daily agent activity log
│   └── FEEDBACK.md                  ✅ Customer feedback log
└── .github/workflows/nexus-ci.yml  ✅ CI/CD (PR checks → ARM64 build → Coolify deploy)
```

---

## The Stack

| Layer | Technology | Cost |
|---|---|---|
| Compute | Oracle Cloud ARM64 (4 OCPUs, 24GB) | **$0** |
| TTS Engine | Kokoro-82M (CPU) | **$0** |
| Voice Cloning | Chatterbox TTS | **$0** |
| STT Engine | faster-whisper | **$0** |
| Telephony | Asterisk 20 LTS | **$0** |
| SIP Trunk | Telnyx ($0.004/min) | ~$5/mo |
| LLM (coding) | Claude Max | **$100/mo** |
| LLM (agents) | Gemini 2.0 Pro / Groq | **$0** |
| Database | PostgreSQL (self-hosted) | **$0** |
| Auth | Clerk | **$0** (free tier) |
| Deployment | Coolify (self-hosted) | **$0** |
| Monitoring | GlitchTip + Langfuse + PostHog | **$0** |
| **TOTAL** | | **~$105/mo** |

---

## Your First Day

Follow these steps to go from zero to your autonomous company running:

### Step 1 — Provision Oracle Cloud Instance

1. Sign up at [oracle.com/cloud/free](https://oracle.com/cloud/free)
2. Create an ARM64 instance (Ampere A1):
   - Shape: `VM.Standard.A1.Flex`
   - OCPUs: 4, RAM: 24GB
   - OS: Ubuntu 22.04 ARM64
   - Storage: 200GB boot volume
3. Note down the public IP address

### Step 2 — Run the Setup Script

From your phone's Termux app (or any SSH client):

```bash
ssh ubuntu@YOUR_ORACLE_IP
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/nexus/main/scripts/setup-oracle.sh | bash
```

This installs everything: Docker, Coolify, all services, Tailscale, SSL. Takes ~15 minutes.

### Step 3 — Configure Telegram Bot

1. Open Telegram → message `@BotFather`
2. Send `/newbot`
3. Name it: **NEXUS CEO**
4. Get your bot token
5. Message `@userinfobot` to get your Telegram user ID
6. Set both in `/opt/nexus/infrastructure/.env`

### Step 4 — Pair WhatsApp

1. Visit `http://YOUR_IP:8040` from your phone
2. Click **Pair WhatsApp**
3. Open WhatsApp → **Linked Devices** → **Link a Device**
4. Scan the QR code

### Step 5 — Send Your First Message

Open Telegram. Find your new **NEXUS CEO** bot. Send:

```
status
```

You'll receive:
```
NEXUS is online. Your autonomous company is ready. 0 tasks, 0 revenue.
All 9 agents standing by. Send 'status' to see your company, or tell
me what to build first.
```

### Step 6 — Tell It What to Build

Reply:
```
Build a Voice AI SaaS platform for B2B sales teams
```

**What happens next:**
1. CEO creates VoiceForge spec in SpecKit
2. Creates 14 Sprint 1 tasks in Beads
3. Assigns to CTO Agent
4. Replies: "Got it! Created spec for VoiceForge. CTO is starting on Sprint 1. I'll update you at noon."

**You go about your day.**

---

### Step 7 — Noon Check-In (12:00 PM)

You receive on Telegram:
```
Midday check-in:

CTO has the landing page 60% done. Database schema complete and
migrations running. Kokoro TTS service benchmarked at 280ms average
on Oracle ARM — faster than expected 🟢

Need your input: pricing copy — $49/$149/$499 good, or adjust?
```

You reply:
```
Yes, looks good
```

---

### Step 8 — Evening Summary (6:00 PM)

You receive:
```
Evening wrap-up:

✅ Shipped: Database schema, Kokoro TTS service, auth setup,
   dashboard skeleton

💰 Revenue: $0 today (building MVP)

🔮 Tomorrow: TTS generator UI, audio player component,
   generation history

Sprint 1: 7/14 tasks done. On track for launch in 8 weeks.
Good progress today. Company is moving.
```

---

**The company is running. You didn't open a terminal.**

---

## Telegram Commands

| Command | What It Does |
|---|---|
| `status` | Full company status (agents, tasks, revenue, errors) |
| `build [description]` | Create spec + tasks + assign to CTO |
| `ship` | Run all checks + deploy to production |
| `money` | Revenue + costs + profit |
| `tasks` | Current task queue with status |
| `approve` | Execute a pending decision |
| `research [topic]` | Trigger Market Scout investigation |
| `call [lead name]` | AI phone call via VoiceForge + Asterisk |
| `briefing` | Audio summary via Telegram voice message |
| `stop everything` | Emergency halt all agents |

---

## VoiceForge — What You're Building

> Self-hosted ElevenLabs + VAPI + Asterisk in one platform

**Why it wins:**
- Teams pay $500–5,000/mo to VAPI + ElevenLabs combined
- VoiceForge: ~$5/mo (SIP trunk only)
- Voice cloning included (ElevenLabs charges $22+/mo)
- Real phone calls via Asterisk (no Twilio markup)
- 100% self-hosted, data never leaves your server
- API-compatible with ElevenLabs (swap base URL, done)

**8-week timeline:**
- Week 1–2: Voice Studio (TTS + voice library)
- Week 2–3: Voice Cloning (10-second zero-shot)
- Week 3–5: Agent Studio (VAPI replacement, browser calls)
- Week 5–7: Phone Studio (Asterisk, real phone calls)
- Week 7–8: Billing + launch

**Target: $1,000 MRR in 90 days.**

---

## Architecture in One Diagram

```
Yash's Phone (Android)
    │
    ├── Telegram ──────────────────────────────────────────────┐
    │                                                           │
    │                                                           ▼
    │                                              ┌─────────────────────┐
    │                                              │   NEXUS CEO Agent   │
    │                                              │   (OpenClaw daemon) │
    │                                              │   Oracle Cloud ARM  │
    │                                              └──────────┬──────────┘
    │                                                         │
    │                    ┌────────────────────────────────────┤
    │                    ▼            ▼             ▼         ▼
    │              ┌──────────┐ ┌──────────┐ ┌─────────┐ ┌──────────┐
    │              │   CTO    │ │  Sales   │ │Support  │ │Marketing │
    │              │ClaudeMax │ │ZeroClaw  │ │ZeroClaw │ │ZeroClaw  │
    │              └──────────┘ └──────────┘ └─────────┘ └──────────┘
    │                    │
    │                    ▼ (builds)
    │         ┌─────────────────────────┐
    │         │       VOICEFORGE         │
    │         │  Next.js + tRPC         │
    │         │  Kokoro TTS             │
    │         │  Whisper STT            │
    │         │  Asterisk Telephony     │
    │         │  Claude/Gemini LLM      │
    │         └─────────────────────────┘
    │                    │
    └────────────────────┘
         WhatsApp (customers)
```

---

## Contributing / Self-Hosting

VoiceForge is open-source (AGPLv3). The NEXUS company layer is the founder's proprietary setup.

To self-host VoiceForge:
1. Clone the repo
2. Copy `.env.example` → `.env`
3. `docker compose up -d`
4. Open `localhost:3000`

Full self-hosting docs: `products/voice-ai-saas/docs/self-hosting.md`

---

*Built by NEXUS CEO Agent — an autonomous AI running on Oracle Cloud, controlled via Telegram.*
