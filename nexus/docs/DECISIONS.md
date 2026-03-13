# Decision Log

All strategic and operational decisions made by NEXUS CEO are logged here.
Format: Date | Decision | Reason | Outcome (updated when known)

---

## Template
```
### YYYY-MM-DD — [Decision Title]
**Made by:** CEO Agent (autonomous) | CEO Agent (founder approved) | Founder direct
**Confidence:** [%] at time of decision
**Decision:** [What was decided]
**Reason:** [Why]
**Alternatives considered:** [What else was considered]
**Outcome:** [TBD / updated when known]
```

---

## 2026-03-13 — First Product: VoiceForge (ElevenLabs + VAPI + Asterisk)

**Made by:** Founder direct
**Confidence:** N/A (founder instruction)
**Decision:** Build VoiceForge — a self-hosted, combined ElevenLabs + VAPI + Asterisk platform for B2B voice AI
**Reason:** Founder identified opportunity: teams paying $500–5,000/mo to VAPI+ElevenLabs combined. VoiceForge offers $0 infrastructure cost alternative. Strong market validation via existing demand.
**Alternatives considered:** (1) Pure TTS clone only, (2) Pure calling agent only, (3) Wrapper service around existing APIs
**Decision rationale:** Combined platform captures the full workflow — voice quality + agent intelligence + real calling. More defensible moat. Higher lifetime value per customer.
**Outcome:** In development. ETA 8 weeks to MVP.

---

## 2026-03-13 — Tech Stack: Next.js + tRPC + Drizzle

**Made by:** CTO Agent (autonomous)
**Confidence:** 95%
**Decision:** Next.js 14 App Router, tRPC v11, Drizzle ORM, PostgreSQL, Clerk auth
**Reason:** Standard modern TypeScript stack. Full type safety. Great developer experience. All ARM64 compatible.
**Alternatives considered:** Remix, SvelteKit, plain Express
**Outcome:** TBD

---

## 2026-03-13 — Pricing: $49/$149/$499 per month

**Made by:** CEO Agent (founder approved)
**Confidence:** 60% (founder approved at midday check-in)
**Decision:** Three tiers at $49, $149, $499/mo
**Reason:** Positioned below VAPI ($0.05/min which equals ~$100/mo for typical usage) + ElevenLabs ($22–99/mo). Our $49 Starter is a clear no-brainer for small teams. $499 Scale captures enterprise without being scary.
**Alternatives considered:** Usage-based only (per minute), $99/$299/$999 (higher), $29/$99/$299 (lower)
**Outcome:** TBD — will A/B test at launch

---

*(New decisions added chronologically as they are made)*
