# VoiceForge — Build Plan

**Product:** VoiceForge (Self-hosted ElevenLabs + VAPI + Asterisk)
**Total Timeline:** 8 weeks to MVP launch
**Builder:** NEXUS CTO Agent (Claude Code Max)
**Infrastructure:** Oracle Cloud ARM, 24GB RAM

---

## Phase 1 — Foundation & Voice Studio
**Duration:** Week 1–2
**Goal:** Users can generate speech and hear it

### 1.1 Project Bootstrap
- [ ] Initialize Next.js 14 (App Router) with TypeScript
- [ ] Configure Tailwind CSS + shadcn/ui component library
- [ ] Set up Drizzle ORM + PostgreSQL connection (InsForge)
- [ ] Configure Clerk auth (or InsForge Auth) with organization support
- [ ] Set up tRPC server + client
- [ ] Configure environment variables structure
- [ ] Set up Langfuse for LLM observability
- [ ] Set up GlitchTip error monitoring (Sentry-compatible SDK)
- [ ] Configure Docker multi-stage build (ARM64)
- [ ] Set up CI/CD via GitHub Actions → Coolify

### 1.2 Kokoro TTS Service
- [ ] Build Python FastAPI service wrapping Kokoro-82M
- [ ] ARM64 Docker image (pytorch CPU build)
- [ ] Endpoints:
  - `POST /tts` — text + voice_id → audio bytes (WAV)
  - `POST /tts/stream` — streaming SSE response (first words fast)
  - `GET /voices` — list available voices
  - `GET /health`
- [ ] Cache warm-up: pre-load model on startup
- [ ] Test: measure latency for 20-word sentence on Oracle ARM
- [ ] 20 system voices seeded (5 male, 5 female, 5 regional, 5 specialty)

### 1.3 Voice Studio UI
- [ ] Dashboard layout (sidebar nav, organization switcher)
- [ ] TTS generator page
  - Text input textarea (with char count)
  - Voice selector (dropdown with preview)
  - Settings sliders (stability, similarity, expressiveness)
  - Generate button + loading state
- [ ] WaveSurfer.js audio player component
  - Play/pause, seek, download
  - Waveform visualization
  - Duration display
- [ ] Generation history list
  - Paginated, filterable
  - Replay, download, delete
  - Voice + settings metadata shown

### 1.4 Storage & Database
- [ ] InsForge Storage bucket for audio files
- [ ] Database schema migrations (Drizzle Kit)
- [ ] tRPC routers: voices, generations
- [ ] Background job: clean up generations > 30 days old (BullMQ)

**Phase 1 Deliverable:** User signs up, generates speech, plays it back, downloads it. ✅

---

## Phase 2 — Voice Cloning
**Duration:** Week 2–3
**Goal:** Users can clone any voice from a 10-second sample

### 2.1 Chatterbox TTS Service
- [ ] Research: test Chatterbox on CPU vs Modal GPU
- [ ] Decision: CPU-only for playback, Modal for cloning generation
- [ ] Build Chatterbox service (Docker or Modal endpoint)
- [ ] Voice cloning endpoint:
  - `POST /clone` — audio file + text → cloned audio
  - `POST /clone/voice` — audio sample → voice embedding (save for reuse)
  - `POST /clone/generate` — voice_embedding + text → audio
- [ ] Quality test: MOS score benchmark on Indian English samples

### 2.2 Voice Clone UI
- [ ] Voice library page
- [ ] "Add Voice" flow:
  - Upload audio sample (drag-drop, up to 60 seconds)
  - Preview playback
  - Name + description form
  - "Clone Voice" button → loading state (10–30 seconds)
  - Success: voice added to library
- [ ] Cloned voice card (name, sample player, usage count)
- [ ] Voice sharing (org-level voices for team plans)
- [ ] Delete voice (with confirmation)

### 2.3 Integration
- [ ] Cloned voices available in TTS generator
- [ ] Voice clone usage logged for billing metering
- [ ] Org voice limits enforced (5 clones on Starter, 25 on Growth)

**Phase 2 Deliverable:** User uploads 10-second voice sample, generates speech in that voice. ✅

---

## Phase 3 — Agent Studio (VAPI Replacement)
**Duration:** Week 3–5
**Goal:** Users can create AI voice agents and test them in-browser

### 3.1 Whisper STT Service
- [ ] Build faster-whisper Python service (ARM64)
- [ ] Docker container with `tiny.en` model (fast, low RAM)
- [ ] Endpoints:
  - `POST /transcribe` — audio bytes → text (batch)
  - `WS /transcribe/stream` — streaming audio chunks → real-time text
- [ ] VAD (Voice Activity Detection): Silero VAD for end-of-speech detection
- [ ] Test latency: 1-second audio chunk → transcript in < 400ms

### 3.2 Agent Orchestrator Service
Core real-time engine — this is the VAPI replacement.

- [ ] Build Node.js/Bun WebSocket server
- [ ] Agent session state machine:
  ```
  IDLE → GREETING → LISTENING → PROCESSING → SPEAKING → LISTENING → ...
  ```
- [ ] Audio pipeline:
  1. Receive audio frames from caller (20ms PCM chunks)
  2. Buffer until VAD detects end-of-speech
  3. Send buffer to Whisper STT → transcript
  4. Send transcript to LLM (with conversation history)
  5. Receive LLM text response (streaming)
  6. Send first sentence to TTS immediately (streaming TTS)
  7. Stream audio back to caller while generating rest
- [ ] LLM integrations:
  - Claude 3.5 Sonnet (Anthropic API)
  - Gemini 2.0 Flash (Google AI Studio API, free)
  - GPT-4o (bring your own key)
  - Ollama local models (optional)
- [ ] Interruption handling: if caller speaks while agent is speaking, stop TTS, re-listen
- [ ] Function calling: agents can call webhooks mid-conversation
- [ ] End call trigger: `endCall()` function available to agent

### 3.3 Agent Management API & UI
- [ ] Agents CRUD (tRPC router)
- [ ] Agent builder UI:
  - Name + description
  - System prompt (large textarea with template library)
  - First message
  - LLM provider + model selector
  - API key input (encrypted storage)
  - STT provider selector
  - Voice selector (any voice from library)
  - Advanced: silence timeout, max duration, webhook URL
- [ ] Agent test page (browser call):
  - WebRTC microphone → Agent Orchestrator WebSocket
  - Real-time transcript display
  - Agent speaking indicator
  - End call button

### 3.4 Call Transcripts & Analytics
- [ ] Calls table in DB
- [ ] Transcript viewer (message-by-message, timestamps)
- [ ] Call recording stored to InsForge Storage
- [ ] Agent analytics dashboard:
  - Total calls, avg duration, completion rate
  - Sentiment breakdown (positive/neutral/negative from LLM analysis)
  - Common topics (word cloud from transcripts)

**Phase 3 Deliverable:** User creates an agent, tests it in browser, has a full conversation. ✅

---

## Phase 4 — Phone Studio (Asterisk Integration)
**Duration:** Week 5–7
**Goal:** AI agents can make and receive real phone calls

### 4.1 Asterisk Setup
- [ ] ARM64 Docker image for Asterisk 20 LTS
  - Build from source if pre-built unavailable
  - Modules needed: `chan_pjsip`, `res_ari`, `res_stasis`, `codec_ulaw`, `codec_opus`
- [ ] ARI (Asterisk REST Interface) configuration
  - REST API on port 8088
  - WebSocket on port 8088/ws
- [ ] PJSIP configuration template for SIP trunks
- [ ] Docker healthcheck + auto-restart

### 4.2 Telephony Bridge Service
Connects Asterisk ↔ Agent Orchestrator:

- [ ] Node.js service subscribing to Asterisk ARI WebSocket
- [ ] On inbound call:
  1. Asterisk fires `StasisStart` event
  2. Bridge starts agent session for assigned agent
  3. Pipe audio: Asterisk External Media → Agent Orchestrator
  4. Pipe audio back: Agent audio → Asterisk ExternalMedia
- [ ] On outbound call:
  1. API request → Asterisk ARI originate
  2. Call dials out via SIP trunk
  3. On answer → same bridge logic as inbound
- [ ] Audio format conversion: PCMU 8kHz (PSTN) ↔ PCM 16kHz (Whisper input)
- [ ] Handle: call hangup, no-answer, busy, error states
- [ ] Handle: DTMF detection (for IVR menus)

### 4.3 SIP Trunk Configuration UI
- [ ] Phone numbers page
- [ ] "Add Number" flow:
  - Select provider (Telnyx, Twilio, Vonage, Custom SIP)
  - Enter SIP credentials (host, username, password)
  - Enter phone number (E.164 format)
  - Test connection button
  - Assign to agent dropdown
- [ ] Number management (edit, delete, reassign)
- [ ] Telnyx integration guide (in-app docs)

### 4.4 Outbound Call API
- [ ] `POST /v1/calls` endpoint
  - Auth: API key
  - Body: `{ "to": "+91XXXXXXXXXX", "agent_id": "xxx" }`
  - Returns: `{ "call_id": "xxx", "status": "initiating" }`
- [ ] `GET /v1/calls/{call_id}` — real-time status
- [ ] `GET /v1/calls/{call_id}/transcript`
- [ ] Call scheduling: `{ "scheduled_at": "2026-03-14T09:00:00Z" }` (BullMQ job)
- [ ] Bulk calls: `POST /v1/calls/batch` with array of numbers

### 4.5 Call Recording
- [ ] Record all calls (both sides) via Asterisk MixMonitor
- [ ] Store raw audio → InsForge Storage / R2
- [ ] Generate MP3 from WAV (ffmpeg)
- [ ] Secure signed URLs for playback (expires after 24h)
- [ ] Transcript linked to recording with timestamp sync

**Phase 4 Deliverable:** Dial a real phone number, AI agent picks up. User can call a lead's number and the AI does the sales call. ✅

---

## Phase 5 — Billing, Polish & Launch
**Duration:** Week 7–8
**Goal:** Paying customers, public launch

### 5.1 Stripe Billing
- [ ] Stripe products + prices (3 tiers)
- [ ] Subscription management UI (upgrade, downgrade, cancel)
- [ ] Usage meters:
  - `tts_characters` — metered per generation
  - `call_minutes` — metered per second, billed per minute
  - `voice_clones` — counted, enforced by plan limit
- [ ] Stripe Meter Events API — fire events on usage
- [ ] Billing page (current plan, usage this month, invoices)
- [ ] Upgrade prompts when limits hit
- [ ] Free trial: 14 days, no credit card

### 5.2 API Keys & Developer Experience
- [ ] API key management page (create, name, revoke)
- [ ] API key auth middleware
- [ ] Auto-generated API docs (OpenAPI spec → Scalar UI)
- [ ] Code examples (curl, Python, Node.js, Go)
- [ ] Migration guide from ElevenLabs (drop-in endpoint compatibility)
- [ ] Migration guide from VAPI

### 5.3 Landing Page
- [ ] Hero: "Your voice AI stack, self-hosted. Zero per-minute fees."
- [ ] Feature comparison table vs ElevenLabs + VAPI (combined)
- [ ] Live demo widget (TTS generator, no signup required)
- [ ] Pricing section (3 tiers + self-host option)
- [ ] Social proof: cost savings calculator
- [ ] CTA: "Start free trial" + "Deploy yourself (GitHub)"

### 5.4 Launch Preparation
- [ ] ProductHunt draft (title, tagline, description, screenshots)
- [ ] Hacker News Show HN post draft
- [ ] Twitter/X launch thread
- [ ] Demo video script (2-minute screen recording)
- [ ] Self-host documentation (README + docs/)
- [ ] GitHub repository polish (README, contributing guide, license)

---

## Tech Decisions Summary

| Decision | Choice | Reason |
|---|---|---|
| TTS | Kokoro-82M | Fast on CPU, Apache 2.0, good quality |
| Voice Cloning | Chatterbox | Zero-shot, no training needed |
| STT | faster-whisper | Best speed/accuracy on CPU |
| LLM default | Gemini 2.0 Flash | Free via AI Studio, fast |
| LLM premium | Claude 3.5 Sonnet | Best conversation quality |
| Telephony | Asterisk 20 | Industry standard, free, ARM64 support |
| SIP Trunk | Telnyx | Best developer API, cheapest rates |
| Database | PostgreSQL + Drizzle | Type-safe, battle-tested |
| Auth | Clerk | Best multi-tenant org support |
| Storage | InsForge / R2 | Self-hosted first, R2 for large files |
| Billing | Stripe | Standard, usage metering built-in |
| Deployment | Coolify + Docker | Git push deploys, free |

---

## Resource Allocation on Oracle Cloud (24GB RAM)

| Service | RAM Budget |
|---|---|
| voiceforge-web (Next.js) | 512MB |
| voiceforge-engine (agent orchestrator) | 1GB |
| kokoro-tts (Python + model) | 2GB |
| chatterbox-tts (Python + model) | 3GB |
| whisper-stt (Python + model) | 1GB |
| asterisk (telephony) | 512MB |
| telephony-bridge (Node.js) | 256MB |
| postgres (database) | 2GB |
| redis (queue + cache) | 512MB |
| coolify (deployment) | 1GB |
| openclaw (CEO agent) | 512MB |
| zeroclaw agents (x6) | 1.5GB |
| other NEXUS services | 3GB |
| **Total** | **~17.5GB** |
| **Headroom** | **~6.5GB** |

All good. 24GB is enough with comfortable headroom.
