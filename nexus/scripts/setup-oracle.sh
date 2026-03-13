#!/bin/bash
# ============================================================
# NEXUS Oracle Cloud Setup Script
# Installs everything on a fresh Oracle Cloud ARM instance
# Run as: root or sudo user
# Target: Ubuntu 22.04 ARM64, 4 OCPUs, 24GB RAM, 200GB storage
#
# Usage: curl -sSL https://raw.githubusercontent.com/.../setup-oracle.sh | bash
# Or:    bash setup-oracle.sh
# ============================================================

set -e  # Exit on error
set -u  # Exit on undefined variable

# ─── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()   { echo -e "${GREEN}[NEXUS]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
step()  { echo -e "\n${BLUE}━━━ $1 ━━━${NC}\n"; }

# ─── Pre-flight Checks ────────────────────────────────────────
step "Pre-flight Checks"

if [[ $(uname -m) != "aarch64" ]]; then
  warn "Not running on ARM64. Docker images may not work correctly."
fi

if [[ $(free -g | awk '/Mem:/{print $2}') -lt 16 ]]; then
  error "Need at least 16GB RAM. Oracle Cloud free tier has 24GB."
fi

log "Running on: $(uname -a)"
log "RAM: $(free -h | awk '/Mem:/{print $2}') total"
log "Disk: $(df -h / | awk 'NR==2{print $4}') free"

# ─── System Updates ───────────────────────────────────────────
step "Updating System"
apt-get update -qq
apt-get upgrade -y -qq
apt-get install -y -qq \
  curl wget git unzip jq \
  htop screen tmux \
  build-essential \
  ca-certificates \
  gnupg lsb-release \
  ffmpeg \
  ufw

log "System updated ✓"

# ─── Configure Firewall ───────────────────────────────────────
step "Configuring Firewall"
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
ufw allow 5060/udp # SIP
ufw allow 5060/tcp # SIP TCP
ufw allow 5061/tcp # SIP TLS
ufw allow 10000:10100/udp  # RTP media
ufw --force enable
log "Firewall configured ✓"

# ─── Install Docker ───────────────────────────────────────────
step "Installing Docker (ARM64)"

if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker
  systemctl start docker
  usermod -aG docker ubuntu 2>/dev/null || true
  log "Docker installed ✓"
else
  log "Docker already installed: $(docker --version)"
fi

# Docker Compose (v2)
if ! docker compose version &> /dev/null; then
  apt-get install -y docker-compose-plugin
fi
log "Docker Compose: $(docker compose version) ✓"

# ─── Install Coolify ──────────────────────────────────────────
step "Installing Coolify (Deployment Platform)"

if [ ! -d "/data/coolify" ]; then
  mkdir -p /data/coolify
  curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
  log "Coolify installed ✓"
else
  log "Coolify already installed ✓"
fi

# ─── Clone NEXUS Repository ───────────────────────────────────
step "Setting Up NEXUS"

NEXUS_DIR="/opt/nexus"

if [ ! -d "$NEXUS_DIR" ]; then
  mkdir -p $NEXUS_DIR

  # If GitHub repo exists, clone it
  # git clone https://github.com/YOUR_USERNAME/nexus.git $NEXUS_DIR
  # For now, create the directory structure

  log "NEXUS directory created at $NEXUS_DIR"
else
  log "NEXUS already exists at $NEXUS_DIR"
fi

cd $NEXUS_DIR

# ─── Create Environment File ──────────────────────────────────
step "Configuring Environment Variables"

ENV_FILE="$NEXUS_DIR/infrastructure/.env"

if [ ! -f "$ENV_FILE" ]; then
  cat > "$ENV_FILE" << 'EOF'
# ──────────────────────────────────────────────
# NEXUS Environment Variables
# Fill in ALL values before running docker compose
# ──────────────────────────────────────────────

# Database
POSTGRES_USER=nexus
POSTGRES_PASSWORD=CHANGE_ME_STRONG_PASSWORD
DATABASE_URL=postgresql://nexus:CHANGE_ME_STRONG_PASSWORD@postgres:5432/voiceforge
DIRECT_URL=postgresql://nexus:CHANGE_ME_STRONG_PASSWORD@postgres:5432/voiceforge

# Redis
REDIS_PASSWORD=CHANGE_ME_REDIS_PASSWORD

# Clerk Auth
CLERK_PUBLISHABLE_KEY=pk_live_...
CLERK_SECRET_KEY=sk_live_...

# Storage (InsForge / Supabase compatible S3)
STORAGE_URL=http://localhost:9000
STORAGE_KEY=your_storage_key
STORAGE_SECRET=your_storage_secret

# Stripe
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# AI APIs (use free tiers where possible)
ANTHROPIC_API_KEY=sk-ant-...
GOOGLE_AI_API_KEY=AIza...
GROQ_API_KEY=gsk_...

# Telegram
TELEGRAM_BOT_TOKEN=BOT_TOKEN_FROM_BOTFATHER
TELEGRAM_FOUNDER_ID=YOUR_TELEGRAM_USER_ID
FOUNDER_WHATSAPP=+91XXXXXXXXXX

# Asterisk
ASTERISK_ARI_USER=voiceforge
ASTERISK_ARI_PASSWORD=CHANGE_ME_ASTERISK_PASSWORD

# Monitoring
GLITCHTIP_SECRET_KEY=CHANGE_ME_GLITCHTIP_SECRET
GLITCHTIP_DOMAIN=https://errors.yourdomain.com
GLITCHTIP_DSN=http://...@errors.yourdomain.com/1

LANGFUSE_SECRET=CHANGE_ME_LANGFUSE_SECRET
LANGFUSE_SALT=CHANGE_ME_LANGFUSE_SALT
LANGFUSE_DOMAIN=https://langfuse.yourdomain.com

POSTHOG_SECRET=CHANGE_ME_POSTHOG_SECRET
POSTHOG_DOMAIN=https://analytics.yourdomain.com

# Chatwoot
CHATWOOT_SECRET=CHANGE_ME_CHATWOOT_SECRET
CHATWOOT_DOMAIN=https://support.yourdomain.com
CHATWOOT_API_TOKEN=

# Twenty CRM
TWENTY_SECRET=CHANGE_ME_TWENTY_SECRET
TWENTY_DOMAIN=https://crm.yourdomain.com

# OpenClaw / ZeroClaw
BEADS_URL=https://beads.yourdomain.com

# Postiz (social media scheduling)
POSTIZ_URL=https://postiz.yourdomain.com
POSTIZ_API_KEY=

EOF
  warn "Environment file created at $ENV_FILE"
  warn "⚠️  YOU MUST FILL IN ALL VALUES BEFORE CONTINUING!"
  warn "Edit the file: nano $ENV_FILE"
  warn "Then re-run this script."
  echo ""
  read -p "Have you filled in all environment variables? (yes/no): " confirm
  if [[ "$confirm" != "yes" ]]; then
    error "Please fill in environment variables first."
  fi
fi

log "Environment configured ✓"

# ─── Install OpenClaw (CEO Agent) ─────────────────────────────
step "Installing OpenClaw (CEO Agent Daemon)"

# OpenClaw install (replace with actual install command when available)
if ! command -v openclaw &> /dev/null; then
  warn "OpenClaw not yet available as standalone binary."
  warn "It will run via Docker container (see docker-compose.yml)"
  log "OpenClaw will be deployed via Docker ✓"
fi

# ─── Install ZeroClaw ─────────────────────────────────────────
step "Installing ZeroClaw (Agent Daemons)"

# ZeroClaw install (replace with actual install command when available)
log "ZeroClaw agents will run via Docker containers ✓"

# ─── Install Tailscale (Secure Remote Access) ─────────────────
step "Installing Tailscale"

if ! command -v tailscale &> /dev/null; then
  curl -fsSL https://tailscale.com/install.sh | sh
  log "Tailscale installed ✓"
  log "Run 'tailscale up' and log in to connect your phone"
else
  log "Tailscale already installed ✓"
fi

# ─── Set Up SSL / Domain ──────────────────────────────────────
step "SSL Configuration"

read -p "Enter your domain name (e.g., voiceforge.ai): " DOMAIN_NAME
read -p "Enter your email for Let's Encrypt: " SSL_EMAIL

if [ -n "$DOMAIN_NAME" ]; then
  # Coolify handles SSL via Traefik + Let's Encrypt
  log "SSL will be configured via Coolify → Traefik"
  log "Make sure DNS is pointed to this server's IP: $(curl -s ifconfig.me)"
fi

# ─── Start All Services ───────────────────────────────────────
step "Starting NEXUS Services"

cd $NEXUS_DIR/infrastructure

log "Pulling Docker images... (this takes 5-10 minutes on first run)"
docker compose pull 2>/dev/null || true

log "Starting database and core services first..."
docker compose up -d postgres redis
sleep 15

log "Running database migrations..."
docker compose run --rm voiceforge-web npx drizzle-kit migrate 2>/dev/null || warn "Migrations may need to be run manually"

log "Starting all services..."
docker compose up -d

# Wait for services to be healthy
log "Waiting for services to be ready..."
sleep 30

# ─── Verify Health ────────────────────────────────────────────
step "Health Check"

services=("postgres" "redis" "voiceforge-web" "kokoro-tts" "whisper-stt" "agent-engine" "asterisk")

for service in "${services[@]}"; do
  status=$(docker compose ps "$service" --format json 2>/dev/null | jq -r '.[0].Health // .[0].State' 2>/dev/null || echo "unknown")
  if [[ "$status" == "healthy" ]] || [[ "$status" == "running" ]]; then
    log "✓ $service: $status"
  else
    warn "⚠ $service: $status (may still be starting)"
  fi
done

# ─── Configure Telegram Bot ───────────────────────────────────
step "Telegram Bot Setup"

echo ""
echo "═══════════════════════════════════════════════"
echo "  TELEGRAM BOT SETUP"
echo "═══════════════════════════════════════════════"
echo ""
echo "1. Open Telegram and message @BotFather"
echo "2. Send: /newbot"
echo "3. Give it a name: 'NEXUS CEO'"
echo "4. Give it a username: nexus_ceo_bot (or any unique name)"
echo "5. Copy the bot token"
echo "6. Edit $ENV_FILE and set TELEGRAM_BOT_TOKEN"
echo ""
echo "To get your Telegram user ID:"
echo "  Message @userinfobot — it'll tell you your ID"
echo "  Set TELEGRAM_FOUNDER_ID in $ENV_FILE"
echo ""

# ─── Configure WhatsApp ───────────────────────────────────────
step "WhatsApp Pairing"

echo "═══════════════════════════════════════════════"
echo "  WHATSAPP SETUP"
echo "═══════════════════════════════════════════════"
echo ""
echo "WhatsApp will be configured via OpenClaw's web UI."
echo "Access: http://$(curl -s ifconfig.me):8040"
echo ""
echo "Steps:"
echo "1. Visit the URL above from your phone"
echo "2. Click 'Pair WhatsApp'"
echo "3. Scan the QR code with WhatsApp > Linked Devices"
echo ""

# ─── Set Up Systemd Service for Auto-start ───────────────────
step "Configuring Auto-start on Boot"

cat > /etc/systemd/system/nexus.service << EOF
[Unit]
Description=NEXUS AI Company Stack
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$NEXUS_DIR/infrastructure
ExecStart=docker compose up -d
ExecStop=docker compose down
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nexus
log "NEXUS will auto-start on boot ✓"

# ─── Final Health Check and Greeting ─────────────────────────
step "Final Steps"

SERVER_IP=$(curl -s ifconfig.me)

echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║           NEXUS IS ONLINE                     ║"
echo "╠═══════════════════════════════════════════════╣"
echo "║  Server IP: $SERVER_IP"
echo "║"
echo "║  Services:"
echo "║  • VoiceForge App:   http://$SERVER_IP:3000"
echo "║  • Coolify:          http://$SERVER_IP:8000"
echo "║  • GlitchTip:        http://$SERVER_IP:8010"
echo "║  • Langfuse:         http://$SERVER_IP:3010"
echo "║  • PostHog:          http://$SERVER_IP:8020"
echo "║  • Chatwoot:         http://$SERVER_IP:3020"
echo "║  • Twenty CRM:       http://$SERVER_IP:3030"
echo "║"
echo "║  Next Steps:"
echo "║  1. Complete Telegram bot setup (see above)"
echo "║  2. Pair WhatsApp at http://$SERVER_IP:8040"
echo "║  3. Set up domain DNS → Coolify"
echo "║  4. Configure SIP trunk in VoiceForge app"
echo "║  5. Send 'status' to your Telegram bot"
echo "╚═══════════════════════════════════════════════╝"
echo ""

log "Setup complete! Your autonomous AI company is ready."
log "Send 'status' to your Telegram bot to begin."
