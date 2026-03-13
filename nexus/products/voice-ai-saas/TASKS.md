# VoiceForge — Task Queue (Beads)

**Format:** [PRIORITY] [ID] [STATUS] Task — Assigned to — Notes

Priority: P0 (blocking), P1 (this sprint), P2 (next sprint), P3 (backlog)
Status: 🔲 todo | 🔄 in-progress | ✅ done | 🔴 blocked

---

## Sprint 1 — Foundation (Week 1)

### Infrastructure
- 🔲 P0 T001 Initialize Next.js 14 project with TypeScript, Tailwind, shadcn/ui — CTO — use `npx create-next-app@latest voiceforge --typescript --tailwind --app`
- 🔲 P0 T002 Set up Drizzle ORM + PostgreSQL schema (users, orgs, voices, generations) — CTO — InsForge connection string from env
- 🔲 P0 T003 Configure Clerk auth with organization support — CTO — multi-tenant from day 1
- 🔲 P0 T004 Set up tRPC v11 server + client — CTO — app router pattern
- 🔲 P0 T005 Configure GlitchTip SDK (Sentry-compatible) — CTO — env: NEXT_PUBLIC_GLITCHTIP_DSN
- 🔲 P0 T006 Configure Langfuse SDK for LLM tracing — CTO — wrap all LLM calls
- 🔲 P0 T007 Create ARM64 Dockerfile for Next.js app — CTO — test locally on Docker Desktop

### Kokoro TTS Service
- 🔲 P0 T008 Build Kokoro TTS FastAPI service — CTO — `services/kokoro-tts/`
  - Install: kokoro, fastapi, uvicorn, soundfile
  - Endpoint: POST /tts → returns WAV bytes
  - Endpoint: POST /tts/stream → SSE streaming
  - Endpoint: GET /voices → voice list
- 🔲 P0 T009 Create ARM64 Docker image for Kokoro service — CTO — pytorch CPU image ~2GB
- 🔲 P0 T010 Seed 20 system voices in database — CTO — migration script with voice metadata
- 🔲 P0 T011 Benchmark Kokoro latency on Oracle ARM (target: <500ms for 20 words) — CTO — document results in ARCHITECTURE.md

### Database Migrations
- 🔲 P0 T012 Create all Drizzle schema files — CTO — voices, generations, agents, calls, phone_numbers, usage_events tables
- 🔲 P0 T013 Run initial migrations on InsForge PostgreSQL — CTO
- 🔲 P0 T014 Create database seed script (system voices, test org) — CTO

---

## Sprint 2 — Voice Studio UI (Week 1–2)

### TTS Generator
- 🔲 P1 T015 Build dashboard layout with sidebar navigation — CTO — shadcn/ui Sidebar component
- 🔲 P1 T016 Build TTS generator page — CTO
  - Text input (max 5000 chars, live count)
  - Voice selector with category filter
  - Settings panel (stability, similarity, expressiveness sliders)
  - Generate button with loading state
  - Error handling display
- 🔲 P1 T017 Build WaveSurfer.js audio player component — CTO — reusable, used everywhere
- 🔲 P1 T018 Build generation history page — CTO
  - List with pagination (20 per page)
  - Each item: voice name, text preview, duration, date, actions
  - Play inline, download MP3, delete

### tRPC Routers
- 🔲 P1 T019 tRPC voices router (list, get, create, delete) — CTO
- 🔲 P1 T020 tRPC generations router (create, list, delete) — CTO
- 🔲 P1 T021 InsForge Storage upload integration (audio files) — CTO — presigned URL upload pattern

---

## Sprint 3 — Voice Cloning (Week 2–3)

### Chatterbox Service
- 🔲 P1 T022 Research Chatterbox install on CPU vs Modal — CTO — benchmark both, decide
- 🔲 P1 T023 Build Chatterbox Docker service (or Modal endpoint) — CTO — `services/chatterbox/`
- 🔲 P1 T024 Voice embedding endpoint: POST /clone/embed — CTO — 10s sample → voice vector (saved to DB)
- 🔲 P1 T025 Generation endpoint: POST /clone/generate — CTO — voice_id + text → audio

### Voice Clone UI
- 🔲 P1 T026 Voice library page — CTO — grid layout, system + cloned voices
- 🔲 P1 T027 "Add Voice" modal — CTO
  - Drag-drop audio upload
  - Preview playback before cloning
  - Name + description form
  - Clone button + progress indicator
- 🔲 P1 T028 Clone quota enforcement (5 on Starter plan) — CTO — check in tRPC router
- 🔲 P1 T029 Org voice sharing (cloned voices visible to all org members) — CTO

---

## Sprint 4 — Agent Studio (Week 3–5)

### STT Service
- 🔲 P1 T030 Build faster-whisper FastAPI service — CTO — `services/whisper-stt/`
  - Model: `tiny.en` (fastest) for real-time, `base.en` for quality
  - VAD: Silero VAD for end-of-speech detection
  - Endpoint: POST /transcribe → text
  - Endpoint: WS /stream → real-time chunks
- 🔲 P1 T031 ARM64 Docker image for Whisper service — CTO
- 🔲 P1 T032 Benchmark STT latency (target: <400ms for 1s audio) — CTO

### Agent Orchestrator
- 🔲 P0 T033 Build WebSocket server (Bun or Node.js) — CTO — `services/agent-engine/`
  - Agent session management
  - Audio frame buffering (20ms PCM chunks)
  - VAD integration → STT → LLM → TTS pipeline
  - Streaming TTS: play first chunk while generating rest
  - Interruption handling
- 🔲 P0 T034 Claude API integration (streaming) — CTO — with Langfuse tracing
- 🔲 P0 T035 Gemini 2.0 Flash integration (default, free) — CTO
- 🔲 P0 T036 BYOK (bring your own key) support — CTO — encrypted key storage in DB
- 🔲 P1 T037 WebRTC browser adapter — CTO — getUserMedia → PCM → WebSocket to engine

### Agent UI
- 🔲 P1 T038 Agent builder page — CTO — form with all agent config fields
- 🔲 P1 T039 Agent test page (browser call) — CTO
  - Mic permission request
  - Connect to agent engine via WebSocket
  - Real-time transcript display
  - Speaking indicator animation
  - End call button
- 🔲 P1 T040 Call history + transcript viewer — CTO
- 🔲 P1 T041 Agent analytics dashboard — CTO — recharts or tremor

---

## Sprint 5 — Asterisk Integration (Week 5–7)

### Asterisk Setup
- 🔲 P0 T042 ARM64 Asterisk 20 Docker image — CTO — test build, document any compilation issues
- 🔲 P0 T043 ARI configuration (REST + WebSocket enabled) — CTO
- 🔲 P0 T044 PJSIP trunk configuration template — CTO — template with env var placeholders
- 🔲 P0 T045 Test Asterisk container on Oracle Cloud — CTO — inbound SIP test call

### Telephony Bridge
- 🔲 P0 T046 Asterisk ARI WebSocket client (Node.js/Bun) — CTO — `services/telephony-bridge/`
- 🔲 P0 T047 Inbound call handler — CTO
  - Stasis app receives call
  - Route to assigned agent
  - Bridge Asterisk ExternalMedia ↔ Agent Orchestrator
- 🔲 P0 T048 Outbound call initiator — CTO
  - ARI originate API call
  - Connect answered call to agent
- 🔲 P0 T049 Audio codec conversion (PCMU 8kHz ↔ PCM 16kHz) — CTO — use ffmpeg or sox in bridge
- 🔲 P0 T050 Call recording via Asterisk MixMonitor — CTO — save to InsForge Storage

### Phone Studio UI
- 🔲 P1 T051 Phone numbers page — CTO — list, add, edit, delete
- 🔲 P1 T052 SIP trunk configuration form — CTO — provider templates + manual input
- 🔲 P1 T053 Test call button (from UI) — CTO — rings phone, agent answers
- 🔲 P1 T054 Outbound call API endpoint — CTO — `POST /api/v1/calls`
- 🔲 P1 T055 Call recording player — CTO — secure presigned URL playback
- 🔲 P2 T056 Bulk outbound calls UI (upload CSV of numbers) — CTO

---

## Sprint 6 — Billing & Launch (Week 7–8)

### Billing
- 🔲 P0 T057 Stripe product + price configuration (3 tiers) — CTO + Finance Agent
- 🔲 P0 T058 Stripe Checkout integration (hosted checkout page) — CTO
- 🔲 P0 T059 Stripe webhook handler (subscription created/updated/cancelled) — CTO
- 🔲 P0 T060 Usage meter events (tts_chars, call_minutes, clone_requests) — CTO
- 🔲 P1 T061 Billing page UI (current plan, usage, invoices) — CTO
- 🔲 P1 T062 Usage limit enforcement middleware — CTO — check limits before each operation
- 🔲 P1 T063 Upgrade prompt components — CTO — shown when limits hit

### API & Docs
- 🔲 P1 T064 API key management UI (create, name, revoke) — CTO
- 🔲 P1 T065 API key auth middleware — CTO
- 🔲 P1 T066 OpenAPI spec generation — CTO — auto from tRPC or manual
- 🔲 P1 T067 Scalar API docs UI — CTO — `GET /docs`

### Landing Page
- 🔲 P1 T068 Landing page (Next.js, same repo) — CTO + Marketing Agent
  - Hero section
  - Feature comparison table
  - Live TTS demo (no auth required)
  - Pricing table
  - Cost calculator widget
- 🔲 P2 T069 Demo video (screen recording + voiceover) — Marketing Agent

---

## Backlog (P2/P3)

- 🔲 P2 T070 Multilingual STT (Whisper multilingual model)
- 🔲 P2 T071 DTMF/IVR support in Agent Studio
- 🔲 P2 T072 Agent transfer to human (warm transfer via SIP)
- 🔲 P2 T073 SMS follow-up after call (via SIP provider API)
- 🔲 P2 T074 Zapier/Make.com integration webhook
- 🔲 P2 T075 HubSpot CRM integration (log calls, update contacts)
- 🔲 P2 T076 Salesforce CRM integration
- 🔲 P2 T077 Twenty CRM integration (built-in, self-hosted)
- 🔲 P2 T078 Real-time sentiment display during call
- 🔲 P3 T079 Custom LLM endpoint (OpenAI-compatible)
- 🔲 P3 T080 Fine-tuned voice models (custom training pipeline)
- 🔲 P3 T081 White-label (custom domain, remove VoiceForge branding)
- 🔲 P3 T082 Multi-region deployment (EU, US, APAC instances)
- 🔲 P3 T083 Conference calls (3-way: customer + AI + human)
- 🔲 P3 T084 VoIP softphone (browser-based, receive calls without SIP trunk)

---

## Task Counts by Sprint
| Sprint | Total Tasks | P0 | P1 |
|---|---|---|---|
| Sprint 1 (Foundation) | 14 | 11 | 3 |
| Sprint 2 (Voice Studio) | 7 | 0 | 7 |
| Sprint 3 (Voice Cloning) | 8 | 0 | 8 |
| Sprint 4 (Agent Studio) | 12 | 4 | 8 |
| Sprint 5 (Asterisk) | 15 | 9 | 6 |
| Sprint 6 (Billing + Launch) | 12 | 3 | 9 |
| **Total MVP** | **68** | **27** | **41** |
