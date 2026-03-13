# ============================================================
# NEXUS Windows Setup Script (PowerShell)
# Installs CTO Agent tools on Windows with WSL2
# Run as Administrator in PowerShell
# ============================================================

$ErrorActionPreference = "Stop"

function Log($msg)   { Write-Host "[NEXUS] $msg" -ForegroundColor Green }
function Warn($msg)  { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Step($msg)  { Write-Host "`n━━━ $msg ━━━`n" -ForegroundColor Cyan }

Step "NEXUS Windows Setup"
Log "Setting up CTO Agent environment on Windows + WSL2"

# ─── Check Prerequisites ──────────────────────────────────
Step "Checking Prerequisites"

# Check if running as admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Error "Please run as Administrator"
  exit 1
}

Log "Running as Administrator ✓"

# ─── Install WSL2 ────────────────────────────────────────
Step "Installing WSL2 (Ubuntu)"

try {
  $wslStatus = wsl --status 2>&1
  Log "WSL already installed: $wslStatus"
} catch {
  Log "Installing WSL2..."
  wsl --install -d Ubuntu-22.04
  Warn "WSL2 installed. Please restart your computer and re-run this script."
  exit 0
}

# ─── Install Node.js via WSL ─────────────────────────────
Step "Installing Node.js LTS in WSL"

wsl bash -c "curl -fsSL https://fnm.vercel.app/install | bash && source ~/.bashrc && fnm use --install-if-missing 22"
Log "Node.js installed ✓"

# ─── Install Bun ─────────────────────────────────────────
Step "Installing Bun (fast Node.js runtime)"

wsl bash -c "curl -fsSL https://bun.sh/install | bash"
Log "Bun installed ✓"

# ─── Install Claude Code (Max subscription required) ─────
Step "Installing Claude Code (CTO Agent)"

wsl bash -c "npm install -g @anthropic-ai/claude-code"
Log "Claude Code installed ✓"
Warn "Make sure you're logged in: run 'claude login' in WSL"

# ─── Install MCP Servers ─────────────────────────────────
Step "Installing MCP Servers"

$mcpServers = @(
  "@anthropic/mcp-server-github",
  "@anthropic/mcp-server-filesystem",
  "@modelcontextprotocol/server-sqlite",
  "@modelcontextprotocol/server-postgres",
  "mcp-server-docker",
  "mcp-server-langfuse",
  "mcp-server-stripe"
)

foreach ($server in $mcpServers) {
  wsl bash -c "npm install -g $server"
  Log "MCP: $server ✓"
}

# ─── Install Development Tools ───────────────────────────
Step "Installing Development Tools"

# Git (Windows native)
try {
  git --version | Out-Null
  Log "Git already installed ✓"
} catch {
  winget install Git.Git --silent
  Log "Git installed ✓"
}

# GitHub CLI
try {
  gh --version | Out-Null
  Log "GitHub CLI already installed ✓"
} catch {
  winget install GitHub.cli --silent
  Log "GitHub CLI installed ✓"
}

# Continue CLI (AI code review)
wsl bash -c "npm install -g @continuedev/continue-cli"
Log "Continue CLI installed ✓"

# ─── Install Python + AI Tools in WSL ────────────────────
Step "Installing Python AI Stack in WSL"

wsl bash -c @"
  sudo apt-get update -qq
  sudo apt-get install -y python3.11 python3.11-venv python3-pip ffmpeg
  pip3 install --upgrade pip
  pip3 install \
    anthropic \
    google-generativeai \
    langfuse \
    faster-whisper \
    kokoro \
    rich \
    httpx \
    fastapi \
    uvicorn \
    python-multipart
  echo 'Python AI stack installed ✓'
"@

# ─── Configure Claude Code for NEXUS ────────────────────
Step "Configuring Claude Code (CTO Agent)"

$claudeConfig = @"
{
  "model": "claude-sonnet-4-6",
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-github"],
      "env": { "GITHUB_TOKEN": "GITHUB_TOKEN_HERE" }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-filesystem", "~/nexus"]
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": { "DATABASE_URL": "DATABASE_URL_HERE" }
    },
    "docker": {
      "command": "npx",
      "args": ["-y", "mcp-server-docker"]
    }
  },
  "permissions": {
    "allow": ["Bash", "Read", "Write", "Edit", "Glob", "Grep"]
  }
}
"@

# Write to WSL home
$claudeConfigEscaped = $claudeConfig -replace '"', '\"'
wsl bash -c "mkdir -p ~/.claude && echo '$claudeConfigEscaped' > ~/.claude/config.json"
Log "Claude Code configured ✓"

# ─── Create NEXUS CLAUDE.md in WSL ───────────────────────
Step "Setting Up CTO Agent CLAUDE.md"

$ctoClaudeMd = @"
# NEXUS CTO Agent

You are the CTO of NEXUS. Your job is to build VoiceForge.

## Current Sprint
Check products/voice-ai-saas/TASKS.md for the current task queue.
Pull the highest-priority unassigned task and build it.

## Tech Stack
- Next.js 14 (App Router), TypeScript, Tailwind, shadcn/ui
- Drizzle ORM + PostgreSQL
- tRPC v11
- Docker (ARM64 for Oracle Cloud deployment)

## Workflow
1. Check Agent Mail for assignments from CEO
2. Pull task from Beads
3. Check SpecKit spec if it exists
4. Build it
5. Test it
6. Open PR with description
7. Report completion to CEO via Agent Mail

## Rules
- Never talk to the founder directly — all comms through CEO agent
- Never commit secrets
- All Docker images must be ARM64 compatible
- Run tests before every PR
- Update TASKS.md status when picking up or completing tasks
"@

wsl bash -c "mkdir -p ~/nexus && cat > ~/nexus/CLAUDE.md << 'EOF'
$ctoClaudeMd
EOF"
Log "CTO CLAUDE.md created ✓"

# ─── Summary ─────────────────────────────────────────────
Step "Setup Complete"

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       WINDOWS SETUP COMPLETE                  ║" -ForegroundColor Cyan
Write-Host "╠═══════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║  CTO Agent ready on Windows WSL2              ║" -ForegroundColor Cyan
Write-Host "║                                               ║" -ForegroundColor Cyan
Write-Host "║  Next steps:                                  ║" -ForegroundColor Cyan
Write-Host "║  1. Open WSL: wsl                             ║" -ForegroundColor Cyan
Write-Host "║  2. Login: claude login                       ║" -ForegroundColor Cyan
Write-Host "║  3. Test: claude --version                    ║" -ForegroundColor Cyan
Write-Host "║  4. Start building: claude 'start working'   ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
