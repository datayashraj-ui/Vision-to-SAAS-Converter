# Oracle Cloud Free Tier Setup Guide

## What You Get (Always Free)

| Resource | Spec |
|---|---|
| Compute | 4 Ampere A1 OCPUs (ARM64) |
| RAM | 24GB |
| Storage | 200GB boot volume |
| Network | 10TB outbound/month |
| Cost | **$0 forever** |

## Step 1: Create Oracle Cloud Account

1. Go to [oracle.com/cloud/free](https://oracle.com/cloud/free)
2. Sign up with credit card (won't be charged for free tier resources)
3. Choose region closest to your customers:
   - India: Mumbai or Hyderabad
   - Global: US East (Ashburn) has most free tier resources

## Step 2: Create ARM64 Instance

1. Go to **Compute → Instances → Create Instance**
2. Name: `nexus-production`
3. Image: Ubuntu 22.04 (ARM64 / aarch64)
4. Shape: Click **Change Shape**
   - Ampere → `VM.Standard.A1.Flex`
   - OCPUs: 4
   - Memory: 24GB
5. Networking: Create new VCN or use default
6. SSH Keys: Upload your public key (or generate new one)
7. Boot Volume: Change to 200GB
8. Click **Create**

## Step 3: Configure Security Rules

1. Go to **Networking → Virtual Cloud Networks → Your VCN**
2. Click **Security Lists → Default Security List**
3. Add **Ingress Rules**:

| Port | Protocol | Source | Description |
|---|---|---|---|
| 22 | TCP | 0.0.0.0/0 | SSH (restrict to your IP later) |
| 80 | TCP | 0.0.0.0/0 | HTTP |
| 443 | TCP | 0.0.0.0/0 | HTTPS |
| 5060 | UDP | Telnyx IPs | SIP from Telnyx |
| 5060 | TCP | Telnyx IPs | SIP TCP |
| 5061 | TCP | 0.0.0.0/0 | SIP TLS |
| 10000-10100 | UDP | 0.0.0.0/0 | RTP Media |

**Telnyx IPs to whitelist for SIP:**
- 192.168.1.0/24 (replace with actual Telnyx SIP IPs from their docs)

4. Also configure Ubuntu's firewall inside the instance (done by setup-oracle.sh)

## Step 4: Point DNS

In your domain registrar or Cloudflare, create A records:

| Subdomain | Points To |
|---|---|
| `app.yourdomain.com` | Oracle Cloud IP |
| `errors.yourdomain.com` | Oracle Cloud IP |
| `analytics.yourdomain.com` | Oracle Cloud IP |
| `support.yourdomain.com` | Oracle Cloud IP |
| `crm.yourdomain.com` | Oracle Cloud IP |

(Or use Cloudflare Tunnels to avoid exposing IP)

## Step 5: Run Setup Script

```bash
# SSH into your instance
ssh ubuntu@YOUR_ORACLE_IP

# Run the setup script
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/nexus/main/scripts/setup-oracle.sh | sudo bash
```

## Monitoring Resource Usage

After deployment, monitor usage:

```bash
# RAM usage
free -h

# Disk usage
df -h

# CPU per container
docker stats --no-stream

# Which containers use most RAM
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}"
```

## Staying Within Free Tier Limits

- CPU: Oracle measures OCPU-hours. 4 OCPUs running 24/7 = within free tier
- RAM: 24GB limit. Our stack uses ~18GB — 6GB headroom
- Storage: 200GB total. Audio files can fill this; clean up generations > 30 days old
- Network: 10TB outbound/month. Should be fine for early stage (audio files are ~1MB each)

## Disaster Recovery

Oracle Cloud free tier VMs can be stopped and started. If the VM becomes unresponsive:

1. Go to Oracle Cloud console
2. Compute → Instances → nexus-production
3. Actions → **Reboot** (soft) or **Force Reboot** (hard)
4. All Docker containers auto-start (configured in setup-oracle.sh)
5. NEXUS system auto-starts via systemd service

## Backup Strategy

Oracle free tier includes:
- 5 volume backups (manual snapshots)
- Take weekly snapshot via Oracle console

For database: set up `pg_dump` cron to InsForge Storage
```bash
# Add to crontab
0 3 * * * docker exec postgres pg_dumpall -U nexus | gzip > /opt/nexus/backups/nexus-$(date +%Y%m%d).sql.gz
```
