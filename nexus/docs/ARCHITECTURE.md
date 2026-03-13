# VoiceForge — Architecture Documentation

**Maintained by:** NEXUS CTO Agent
**Last updated:** 2026-03-13

---

## System Overview

VoiceForge is a monorepo containing:
1. **Next.js web application** — UI + tRPC API
2. **Microservices** — specialized AI/audio/telephony services
3. **Infrastructure** — Docker Compose, CI/CD

All services run on a single Oracle Cloud ARM64 instance via Docker Compose.

---

## Service Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Oracle Cloud ARM64                          │
│                    (4 OCPUs, 24GB RAM)                          │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Traefik (Coolify)                      │  │
│  │              SSL Termination + Routing                    │  │
│  └────┬───────────────────┬───────────────────┬─────────────┘  │
│       │                   │                   │                  │
│       ▼                   ▼                   ▼                  │
│  ┌─────────┐    ┌───────────────┐    ┌──────────────┐          │
│  │Next.js  │    │Agent Engine   │    │Telephony     │          │
│  │Web App  │    │WebSocket srv  │    │Bridge        │          │
│  │:3000    │    │:8882          │    │:8883         │          │
│  └────┬────┘    └──────┬────────┘    └──────┬───────┘          │
│       │                │                     │                  │
│       └────────────────┼─────────────────────┘                  │
│                        │                                         │
│          ┌─────────────┼─────────────────┐                     │
│          ▼             ▼                 ▼                      │
│  ┌────────────┐ ┌────────────┐ ┌──────────────┐               │
│  │Kokoro TTS  │ │Whisper STT │ │Asterisk      │               │
│  │:8880       │ │:8881       │ │:5060,:8088   │               │
│  └────────────┘ └────────────┘ └──────────────┘               │
│                                                                 │
│  ┌────────────┐ ┌────────────┐                                 │
│  │Chatterbox  │ │Redis       │                                 │
│  │:8879       │ │:6379       │                                 │
│  └────────────┘ └────────────┘                                 │
│                                                                 │
│  ┌──────────────────────────────────────────────┐              │
│  │              PostgreSQL :5432                 │              │
│  │  [voiceforge] [glitchtip] [langfuse]          │              │
│  │  [posthog] [chatwoot] [twenty] [cognee]       │              │
│  └──────────────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Real-Time Call Architecture

### WebRTC Browser Call Flow
```
Browser (Mic) ──WebRTC──▶ Daily.co/WebRTC server
                                    │
                                    ▼ (audio stream)
                          Agent Engine (WebSocket)
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
              Whisper STT      LLM (Claude)    Kokoro TTS
              (transcribe)     (respond)       (speak)
                    └───────────────┼───────────────┘
                                    │
                          Agent Engine ──▶ Browser (audio)
```

### PSTN Phone Call Flow
```
PSTN/SIP ──▶ SIP Trunk Provider (Telnyx)
                    │
                    ▼ (SIP INVITE)
              Asterisk :5060
                    │
                    ▼ (ARI StasisStart event)
         Telephony Bridge :8883
                    │
                    ▼ (WebSocket audio frames, 20ms, G.711 μ-law)
          Agent Engine :8882
                    │
           ┌────────┴────────┐
           ▼                 ▼
     Whisper STT        Kokoro TTS
     (G.711→PCM16k)     (PCM16k→G.711)
           │                 │
           ▼                 ▼
     Claude/Gemini ──▶ Audio response
                    │
                    ▼ (audio back)
         Telephony Bridge
                    │
                    ▼ (ExternalMedia)
              Asterisk
                    │
                    ▼ (RTP audio)
              SIP Trunk ──▶ PSTN ──▶ Caller's Phone
```

---

## Database Design

### Schema Principles
- All IDs are UUIDs (v7 for time-ordered sorting)
- `created_at` and `updated_at` on every table (Drizzle timestamps)
- Soft deletes where data has value (`deleted_at` column)
- Row-level security enforced at application layer (org_id checks in every query)
- Encrypted sensitive fields: `api_key_encrypted`, `sip_credentials_encrypted`

### Key Relationships
```
organizations
  └── users (many per org)
  └── voices (many per org, some global system voices)
  └── tts_generations (many per org)
  └── agents (many per org)
  └── phone_numbers (many per org)
  └── calls (many per org, linked to agent + phone_number)
  └── usage_events (many per org, for billing metering)
```

---

## Audio Pipeline Details

### STT Pipeline
1. Caller audio arrives as G.711 μ-law, 8kHz, mono PCM
2. Telephony Bridge converts to PCM 16kHz (ffmpeg)
3. Silero VAD processes frames for speech detection
4. On end-of-speech: buffer sent to Whisper STT
5. `faster-whisper` processes with `tiny.en` model (CPU int8 quantized)
6. Returns text + confidence score
7. If confidence < 0.7: request repeat ("Sorry, could you repeat that?")

### TTS Pipeline
1. LLM response arrives as text stream (chunks)
2. First sentence detection: buffer until first "." or "?" or "!"
3. First sentence sent to Kokoro TTS immediately (low latency first word)
4. Remaining text buffered and sent in 50-word chunks
5. Kokoro returns WAV at 24kHz
6. Resampled to 8kHz G.711 for PSTN, or sent as-is for WebRTC
7. Streamed back to caller with crossfade between chunks

### Interruption Handling
1. VAD detects speech while TTS audio is playing
2. Agent Engine immediately stops queueing TTS audio
3. Asterisk/WebRTC stops playing audio (via Bridge channel control)
4. New transcription starts from the beginning
5. Previous LLM request is cancelled (streaming abort)

---

## Security Architecture

### Secrets Management
- Never stored in git (TruffleHog CI check)
- Environment variables loaded from `.env` (not committed)
- Database credentials rotated every 90 days
- API keys encrypted at rest using AES-256 (key from env)
- Asterisk SIP credentials encrypted in DB

### Network Security
- All services on private Docker network (not exposed externally)
- Only Traefik exposes ports 80/443 externally
- Asterisk SIP port (5060) filtered to SIP trunk IPs only
- Tailscale for admin access (no exposed SSH port)
- Oracle Cloud security group: only 22, 80, 443, 5060 inbound

### Authentication
- Clerk handles user auth (OAuth, magic links, passkeys)
- API key auth for programmatic access (hashed in DB, never logged)
- Organization isolation enforced in every tRPC resolver

---

## Performance Targets

| Operation | P50 | P95 | P99 |
|---|---|---|---|
| TTS generation (20 words) | 180ms | 400ms | 800ms |
| STT transcription (1s audio) | 150ms | 350ms | 700ms |
| LLM first token (Claude) | 300ms | 700ms | 1500ms |
| End-to-end call turn (PSTN) | 700ms | 1500ms | 2500ms |
| Web API response (p50) | 50ms | 200ms | 500ms |
| TTS page load (FCP) | 800ms | 1500ms | 3000ms |

---

## Decision Log (Architecture Decisions)

### 2026-03-13 — Chose Kokoro over Coqui for TTS
**Decision:** Use Kokoro-82M as primary TTS engine
**Reason:** Lower memory (800MB vs 2GB), faster inference on CPU, Apache 2.0 license
**Trade-off:** Slightly less expressive than Coqui XTTS-v2, fewer languages
**Revisit:** If customers need more language support or expressiveness

### 2026-03-13 — Chose faster-whisper over Whisper.cpp
**Decision:** Use faster-whisper (CTranslate2) for STT
**Reason:** Better performance on CPU via int8 quantization, Python-native API
**Trade-off:** Larger binary than whisper.cpp
**Revisit:** If latency becomes an issue

### 2026-03-13 — Chose Telnyx over Twilio as default SIP trunk
**Decision:** Telnyx recommended in UI as default SIP provider
**Reason:** Better developer API, lower rates ($0.004/min vs Twilio $0.014/min), no per-number monthly fee on cheapest plan
**Trade-off:** Less brand recognition for users coming from Twilio
**Revisit:** If users report Telnyx quality issues

### 2026-03-13 — Chose tRPC over REST for internal API
**Decision:** Use tRPC v11 for all Next.js API endpoints
**Reason:** Type safety end-to-end, no manual API type generation, great DX
**Trade-off:** Not usable from non-TypeScript clients directly (but we expose `/api/v1` REST for external API)
**Revisit:** Never — this is the right call for a TypeScript monorepo
