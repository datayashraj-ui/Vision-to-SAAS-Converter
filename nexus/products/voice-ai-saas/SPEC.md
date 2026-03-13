# VoiceForge — Product Specification

**Version:** 1.0
**Status:** In Development
**Owner:** NEXUS CTO Agent
**Created:** 2026-03-13

---

## What Is VoiceForge

VoiceForge is a **100% self-hosted voice AI platform** that combines:

| Platform | What We Replace | Our Implementation |
|---|---|---|
| **ElevenLabs** | Text-to-speech, voice cloning, voice library | Kokoro TTS + Chatterbox zero-shot cloning |
| **VAPI** | AI voice agent orchestration (STT→LLM→TTS pipeline) | Custom WebSocket engine + Claude/Gemini |
| **Asterisk** | SIP telephony for real phone calls | Asterisk 20 LTS via Docker (ARM64) |

**One platform. One subscription ($0 infra). Unlimited usage.**

---

## The Problem We Solve

| Pain Point | ElevenLabs | VAPI | VoiceForge |
|---|---|---|---|
| Price per minute | $0.0003/char | $0.05/min + provider costs | $0 (self-hosted) |
| Voice cloning locked behind paywall | ✅ Creator tier ($22/mo) | ❌ N/A | ✅ Free, unlimited |
| Real phone calls (PSTN) | ❌ No | ✅ Via Twilio ($1+/mo/number) | ✅ Via Asterisk SIP trunk ($0–$3/mo) |
| Data stays on your server | ❌ | ❌ | ✅ Always |
| Full API control | Partial | Partial | ✅ You own everything |
| Custom LLM | ❌ | ✅ | ✅ |

---

## Target Users

**Primary:** B2B SaaS builders, AI agencies, sales automation companies who:
- Are paying $500–$5,000/mo to VAPI + ElevenLabs combined
- Want data sovereignty (healthcare, legal, finance)
- Need custom voice personas at scale
- Want to run outbound AI call campaigns

**Secondary:** Indie developers who want a personal voice AI assistant with a real phone number.

---

## Pricing

| Tier | Price | Limits | Target |
|---|---|---|---|
| **Starter** | $49/mo | 5 voices, 10,000 TTS chars/day, 100 call minutes/mo, 1 phone number | Solo founder, small startup |
| **Growth** | $149/mo | 25 voices, 100,000 TTS chars/day, 1,000 call minutes/mo, 5 phone numbers, voice cloning | Growing team, agency |
| **Scale** | $499/mo | Unlimited voices, unlimited TTS, unlimited calls, 20 numbers, priority GPU, API access, white-label | Enterprise, large agencies |
| **Self-Host** | $0 (OSS) | Deploy yourself, community support | Developers, privacy-first |

---

## Core Features

### 1. Voice Studio (ElevenLabs replacement)
- **Text-to-Speech** — paste any text, hear it spoken
  - Choose voice from library (20 built-in system voices)
  - Adjust: stability, similarity, expressiveness, style exaggeration
  - Supported languages: EN, HI, ES, PT, FR, DE, JA, ZH
  - Accents: Indian English, British, American, Australian, South African
- **Voice Cloning** — zero-shot, 10-second sample
  - Upload audio sample → instant custom voice
  - No fine-tuning, no waiting
  - Works with Chatterbox TTS model
- **Voice Library** — manage all voices
  - System voices (pre-seeded)
  - Cloned voices (per user)
  - Shared org voices (team plan)
- **Generation History** — all TTS outputs saved
  - Waveform player (WaveSurfer.js)
  - Download as MP3/WAV
  - Metadata: voice used, settings, character count

### 2. Agent Studio (VAPI replacement)
- **Create Voice Agents** — configure an AI phone agent
  - System prompt (agent personality/instructions)
  - Choose LLM: Claude 3.5 Sonnet, Gemini 2.0 Flash, GPT-4o (bring your own key)
  - Choose STT: Whisper (self-hosted, free), Deepgram (bring API key)
  - Choose TTS: VoiceForge built-in (free), ElevenLabs (bring API key)
  - First message (what agent says when call connects)
  - Silence detection timeout
  - Max call duration
- **Test Agent in Browser** — WebRTC call right from the dashboard
- **Agent Analytics** — call volume, avg duration, completion rate, sentiment
- **Webhooks** — POST call events to your backend (call started, ended, transcript ready)
- **Call Transcripts** — full text + timestamps for every call

### 3. Phone Studio (Asterisk integration)
- **Phone Numbers** — provision via SIP trunk providers
  - Supported: Twilio, Telnyx, Vonage, VoIP.ms, any SIP trunk
  - Assign numbers to agents
- **Inbound Calls** — customer calls number → routed to AI agent
- **Outbound Calls** — trigger a call via API
  - `POST /api/calls/outbound` with `to`, `agent_id`
  - Agent calls the number, introduces itself, runs conversation
- **Call Routing** — conditional routing based on agent response
  - Transfer to human (`transferCall(number)`)
  - Send SMS follow-up after call
  - Trigger webhook with outcome
- **Call Recording** — stored in Cloudflare R2 / InsForge Storage
- **Dial Plans** — custom Asterisk dial plans via UI (advanced users)

### 4. API (developer-first)
REST API + WebSocket API mirroring ElevenLabs and VAPI interfaces where possible for easy migration.

```
# TTS (ElevenLabs-compatible endpoint)
POST /v1/text-to-speech/{voice_id}
POST /v1/text-to-speech/{voice_id}/stream

# Voice Management
GET  /v1/voices
POST /v1/voices/add          # clone a voice
GET  /v1/voices/{voice_id}

# Agents
POST /v1/agents
GET  /v1/agents/{agent_id}
PUT  /v1/agents/{agent_id}

# Calls
POST /v1/calls               # initiate outbound call
GET  /v1/calls/{call_id}     # get call details
GET  /v1/calls/{call_id}/transcript
GET  /v1/calls/{call_id}/recording

# WebSocket (real-time agent)
WS   /v1/connect/{agent_id}  # for browser/app voice sessions
```

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    VOICEFORGE PLATFORM                       │
│                  (Oracle Cloud ARM, 24GB)                    │
│                                                             │
│  ┌──────────────┐     ┌──────────────────────────────────┐  │
│  │  Next.js UI  │────▶│        API Layer (tRPC)           │  │
│  │  Port 3000   │     │        Next.js API Routes         │  │
│  └──────────────┘     └────────────┬─────────────────────┘  │
│                                    │                         │
│              ┌─────────────────────┼──────────────────────┐  │
│              ▼                     ▼                       ▼  │
│  ┌──────────────────┐  ┌────────────────────┐  ┌────────────┐│
│  │   Voice Engine   │  │  Agent Orchestrator │  │ Telephony  ││
│  │  Kokoro TTS      │  │  WebSocket Server   │  │ Asterisk   ││
│  │  Chatterbox Clone│  │  STT + LLM + TTS    │  │ AMI/ARI    ││
│  │  Port 8880       │  │  Port 8881          │  │ Port 5060  ││
│  └──────────────────┘  └────────────────────┘  └────────────┘│
│              │                     │                       │  │
│              └─────────────────────┼──────────────────────┘  │
│                                    ▼                         │
│                    ┌───────────────────────────┐             │
│                    │        Data Layer          │             │
│                    │  PostgreSQL  │  Redis       │             │
│                    │  InsForge    │  MinIO/R2    │             │
│                    └───────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
         │                                    │
         ▼                                    ▼
   Browser / App                      PSTN / SIP Trunk
   (WebRTC calls)                     (Real phone calls)
```

### Real-Time Call Flow (outbound)
```
1. POST /v1/calls {to: "+91XXXXXXXXXX", agent_id: "sales-agent"}
2. Agent Orchestrator → Asterisk ARI → originate call to PSTN
3. Call connects → Asterisk streams audio to Agent Orchestrator via WebSocket
4. Audio chunk arrives (20ms frames, 8kHz μ-law PCM)
   → Whisper STT → transcript chunk
5. When end-of-utterance detected → full user text sent to LLM
6. LLM generates response text → Kokoro TTS → audio
7. Audio streamed back to Asterisk → played to caller
8. Loop until call ends
9. Full transcript saved → webhook fired → recording saved to storage
```

### Latency Budget (CPU-only, Oracle ARM)
| Stage | Target | Realistic |
|---|---|---|
| STT (Whisper tiny, 1s audio) | <300ms | 150–400ms |
| LLM response (first token) | <500ms | 300–800ms |
| TTS (Kokoro, 20 words) | <400ms | 200–500ms |
| **Total response latency** | **<1.2s** | **650ms–1.7s** |

> Sub-second responses are achievable for short utterances. For longer, more natural conversation, streaming TTS is essential (speak first words while generating the rest).

---

## Technical Stack

### Frontend
- **Framework:** Next.js 14 (App Router), TypeScript, React 19
- **Styling:** Tailwind CSS + shadcn/ui
- **Audio visualization:** WaveSurfer.js
- **WebRTC:** Daily.co SDK (browser calls) or native WebRTC
- **Real-time:** Socket.io client (call status updates)
- **State:** Zustand + TanStack Query

### Backend
- **API:** tRPC + Next.js API routes
- **Auth:** Clerk (multi-tenant orgs) or InsForge Auth
- **ORM:** Drizzle ORM + PostgreSQL
- **Storage:** Cloudflare R2 / InsForge Storage (S3-compatible)
- **Queue:** BullMQ + Redis (background TTS jobs, call scheduling)
- **Billing:** Stripe (subscriptions + usage metering)

### AI / Voice Services
- **TTS:** Kokoro-82M (runs on ARM CPU, ~200ms latency)
- **Voice Cloning:** Chatterbox TTS via Modal (serverless GPU) or local if GPU available
- **STT:** faster-whisper (whisper.cpp ARM build, tiny/base model)
- **LLM:** Claude 3.5 Sonnet via API (or Gemini Flash, bring-your-own-key)
- **Fallback TTS:** Coqui XTTS-v2 (CPU, slower but higher quality)

### Telephony
- **SIP Server:** Asterisk 20 LTS (ARM64 Docker)
- **Control Interface:** Asterisk ARI (REST + WebSocket)
- **SIP Trunk:** Telnyx / Twilio / VoIP.ms (customer provides credentials)
- **Codecs:** PCMU (G.711 μ-law, 8kHz) for PSTN, Opus for WebRTC
- **DTMF:** RFC 2833 for IVR support

### Infrastructure
- **Container runtime:** Docker (ARM64)
- **Orchestration:** Docker Compose (single node, Oracle Cloud)
- **Deployment:** Coolify (Git push → auto-deploy)
- **SSL:** Let's Encrypt via Coolify/Caddy
- **Monitoring:** GlitchTip (errors) + Langfuse (LLM calls) + PostHog (product analytics)
- **CDN:** Cloudflare (free tier) in front of Oracle Cloud

---

## Database Schema (Key Tables)

```sql
-- Users & Organizations (managed by Clerk/InsForge Auth)
organizations (id, name, stripe_customer_id, plan, created_at)
users (id, org_id, email, role, created_at)

-- Voice Library
voices (
  id, org_id, name, description, category, locale,
  is_system, preview_url, model, settings_json,
  sample_file_url, created_at
)

-- TTS Generations (history)
tts_generations (
  id, org_id, user_id, voice_id, text, char_count,
  audio_url, duration_ms, settings_json, created_at
)

-- Agents
agents (
  id, org_id, name, system_prompt, first_message,
  llm_provider, llm_model, llm_api_key_encrypted,
  stt_provider, tts_voice_id,
  silence_timeout_ms, max_duration_s,
  webhook_url, created_at, updated_at
)

-- Phone Numbers
phone_numbers (
  id, org_id, number, sip_trunk_provider,
  sip_credentials_encrypted, assigned_agent_id,
  created_at
)

-- Calls
calls (
  id, org_id, agent_id, phone_number_id,
  direction, -- inbound | outbound
  from_number, to_number,
  status, -- pending | in_progress | completed | failed
  duration_s, recording_url, transcript_json,
  cost_cents, started_at, ended_at, created_at
)

-- Usage (for billing metering)
usage_events (
  id, org_id, type, -- tts_chars | call_minutes | clone_requests
  quantity, created_at
)
```

---

## MVP Scope (What We Build First)

### Phase 1 — Voice Studio (Week 1–2)
- [ ] Auth (Clerk or InsForge Auth)
- [ ] Dashboard shell (Next.js App Router)
- [ ] Kokoro TTS integration (Docker service)
- [ ] 20 system voices seeded in DB
- [ ] TTS generation UI + history
- [ ] WaveSurfer.js waveform player
- [ ] File storage (InsForge/R2)

### Phase 2 — Voice Cloning (Week 2–3)
- [ ] Chatterbox TTS service (Modal or local Docker)
- [ ] Voice upload UI (10-second sample)
- [ ] Zero-shot cloning pipeline
- [ ] Cloned voice management

### Phase 3 — Agent Studio (Week 3–5)
- [ ] Agent CRUD (create, edit, delete agents)
- [ ] Agent WebSocket server (Node.js + Bun)
- [ ] Whisper STT service (Docker, faster-whisper)
- [ ] LLM integration (Claude via API)
- [ ] Browser test calls (WebRTC)
- [ ] Transcript storage + viewer

### Phase 4 — Phone Studio / Asterisk (Week 5–7)
- [ ] Asterisk Docker container (ARM64)
- [ ] ARI WebSocket bridge (connect Asterisk to Agent Orchestrator)
- [ ] SIP trunk configuration UI
- [ ] Inbound call routing
- [ ] Outbound call API
- [ ] Call recording + storage
- [ ] Real E2E test call

### Phase 5 — Billing + Launch (Week 7–8)
- [ ] Stripe subscriptions (Starter/Growth/Scale tiers)
- [ ] Usage metering (Stripe Meters)
- [ ] Usage dashboard
- [ ] Landing page (conversion-focused)
- [ ] Docs site (API reference)
- [ ] ProductHunt launch preparation

---

## Success Criteria

| Metric | Target |
|---|---|
| TTS latency (first audio byte) | < 500ms |
| Call response latency (end-to-end) | < 1.5s |
| Concurrent calls supported | 10+ on Oracle ARM free tier |
| Uptime | 99.5%+ |
| Voice cloning quality (MOS score) | > 3.5/5 |
| Time to first customer | Week 8 |
| MRR at 90 days | $1,000+ |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Kokoro TTS too slow on ARM CPU | Medium | High | Stream output, run concurrent workers, fallback to Coqui |
| Asterisk ARM Docker image stability | Low | High | Use pre-built asterisk/asterisk:20 ARM, tested |
| SIP trunk integration complexity | Medium | Medium | Start with Telnyx (best API), Twilio as fallback |
| Chatterbox cloning quality on CPU | High | Medium | Use Modal for cloning (GPU), serve cached clones locally |
| Oracle Cloud RAM exhaustion | Medium | Medium | Profile all services, swap to disk for non-critical ones |
| Whisper STT accuracy (accents) | Medium | Medium | Use Whisper base.en for English, support Deepgram fallback |

---

## References
- **Resonance (inspiration):** https://github.com/code-with-antonio/resonance
- **Kokoro TTS:** https://github.com/hexgrad/kokoro
- **Chatterbox TTS:** https://github.com/resemble-ai/chatterbox
- **faster-whisper:** https://github.com/SYSTRAN/faster-whisper
- **Asterisk ARI:** https://docs.asterisk.org/Configuration/Interfaces/Asterisk-REST-Interface-ARI/
- **ElevenLabs API reference:** https://elevenlabs.io/docs/api-reference
- **VAPI API reference:** https://docs.vapi.ai/api-reference
