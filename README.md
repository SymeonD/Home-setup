# Home-setup

Fully automated homelab provisioning with Ansible — from a bare Ubuntu server to a running stack of self-hosted services in a single command.

## What this does

Provisions and configures a personal homelab server with:

| Service | Role |
|---|---|
| **Traefik** | Reverse proxy, automatic TLS via Let's Encrypt |
| **Immich** | Self-hosted photo library with ML tagging |
| **Nextcloud** | File storage and collaboration suite |
| **Minecraft** | Family game server with metrics exporter |
| **Prometheus + Loki** | Metrics and log aggregation |
| **Grafana** | Monitoring dashboards (system + per-service) |
| **Restic + pg_dump** | Automated daily backups with retention policy |
| **LVM** | Logical volume management for data and backup disks |

## Architecture

```
Internet
   │
   ▼
[Traefik :80/:443]  ── Let's Encrypt (ACME)
   │    traefik-net (Docker external network)
   ├──▶ [Immich :2283]         ── immich-net ──▶ [PostgreSQL] [Redis] [ML]
   ├──▶ [Nextcloud]            ── nextcloud-net ▶ [PostgreSQL] [Redis]
   ├──▶ [Grafana :3000]
   └──▶ [Traefik dashboard]

[Minecraft :25565]  ── monitoring-net ──▶ [minecraft-exporter :9150]

monitoring-net (Docker external network)
   ├── [Prometheus]  ◀── node-exporter, cAdvisor, Loki, minecraft-exporter
   ├── [Loki]        ◀── Promtail (host logs + Docker container logs)
   └── [Grafana]     ──▶ Prometheus, Loki (provisioned datasources)

Storage (LVM on /dev/nvme0n1)
   ├── /var/lib/docker  (50 GB)
   └── /srv/data        (800 GB)

Backup disk (LVM on /dev/sda)
   └── /srv/backup      (full disk)
       ├── restic-repo/         (file snapshots — 7d/4w/12m retention)
       └── postgres/YYYY-MM-DD/ (pg_dumpall — 30d retention)
```

## Prerequisites

**Control machine:**
- Ansible 2.17+
- `community.docker` collection: `ansible-galaxy collection install community.docker`

**Target server:**
- Ubuntu 22.04 or 24.04 LTS (amd64)
- 16 GB RAM minimum (32 GB recommended)
- NVME/SSD disk with at minimum:
  - 100 GB root (`/`)
  - 50 GB for Docker (`/var/lib/docker`)
  - 800 GB for application data (`/srv/data`)
- Optional HDD/second disk for backups (`/srv/backup`)
- SSH access with sudo privileges

## Quick Start

```bash
# Clone
git clone https://github.com/SymeonD/Home-setup.git
cd Home-setup

# Configure your inventory
cp ansible/inventory.example ansible/inventory
# Edit ansible/inventory with your server IP/hostname

# Configure variables
cp ansible/group_vars/all/vault.yml.example ansible/group_vars/all/vault.yml
ansible-vault encrypt ansible/group_vars/all/vault.yml

# Run
ansible-playbook -i ansible/inventory ansible/homelab.yml --ask-vault-pass --ask-become-pass
```

## Configuration

Variables are split across two files in `ansible/group_vars/all/`:

**`all.yml`** — public configuration:
```yaml
docker_root: /opt/docker     # Docker Compose project directories
data_root:   /srv/data       # Application data volumes
backup_root: /srv/backup     # Backup destination
timezone:    Europe/Paris
```

**`vault.yml`** — encrypted secrets (Ansible Vault AES256):

| Variable | Used by |
|---|---|
| `vault_domain` | Traefik TLS, all service URLs |
| `vault_email` | Let's Encrypt registration |
| `postgres_password` | Immich & Nextcloud databases |
| `jwt_secret` | Immich authentication |
| `nextcloud_admin_user` | Nextcloud initial admin |
| `nextcloud_admin_password` | Nextcloud initial admin |
| `rcon_password` | Minecraft RCON + exporter |
| `restic_password` | Restic backup repository |

To edit secrets:
```bash
ansible-vault edit ansible/group_vars/all/vault.yml
```

## Project Structure

```
ansible/
├── homelab.yml                    # Main playbook (role execution order)
├── inventory.example              # Inventory template
├── group_vars/all/
│   ├── all.yml                    # Public variables
│   └── vault.yml                  # Encrypted secrets
└── roles/
    ├── system/                    # OS: packages, firewall (UFW), fail2ban, timezone, swap
    ├── storage/                   # LVM volumes and mount points
    ├── docker/                    # Docker Engine install (apt, GPG-verified)
    ├── traefik/                   # Reverse proxy + TLS
    ├── immich/                    # Photo management
    ├── nextcloud/                 # File storage
    ├── minecraft/                 # Game server
    ├── monitoring_collectors/     # node-exporter, cAdvisor, Promtail
    ├── prometheus/                # Prometheus + Loki
    ├── grafana/                   # Dashboards (provisioned from JSON)
    └── backup/                    # Restic + pg_dump cron jobs
```

## Backup & Restore

### Schedule

| Job | Time | Destination |
|---|---|---|
| PostgreSQL dump (`pg_dumpall`) | 02:00 daily | `/srv/backup/postgres/YYYY-MM-DD/` |
| Restic snapshot (files) | 04:00 daily | `/srv/backup/restic-repo/` |

Restic retention: 7 daily, 4 weekly, 12 monthly snapshots.
PostgreSQL dumps: 30-day rolling window.

### Restore

```bash
# List available restore dates
sudo restic snapshots --group-by tags

# Restore from a specific date
sudo restore-homelab 2025-01-15
```

The restore script (`/usr/local/bin/restore-homelab`) handles the full sequence: stops services, clears data directories, restores Restic snapshots, restores PostgreSQL dumps, restarts services.

Manual restore if needed:

```bash
# Restic file restore
sudo restic restore <snapshot-id> --target / --path /srv/data/immich

# PostgreSQL restore
gunzip -c /srv/backup/postgres/2025-01-15/immich_dump.sql.gz \
  | docker exec -i immich-postgres psql --username=postgres --dbname=immich
```

## Security

- All secrets stored in Ansible Vault (AES256) — never committed in plaintext
- Restic password stored in `/root/.restic-password` (mode `0400`) — not exposed in scripts or environment
- Backup/restore scripts restricted to root (`0700`)
- UFW default-deny inbound; only SSH, 80, 443, 25565 open
- fail2ban active with 24h SSH ban after 3 failures
- Docker installed via official apt repository with GPG signature verification
- Traefik exposes services by default only when explicitly labelled (`exposedByDefault: false`)
- All Docker networks isolated by service group

## Networking

| Network | Type | Members |
|---|---|---|
| `traefik-net` | external | Traefik, Immich, Nextcloud, Grafana, Minecraft |
| `immich-net` | bridge | immich-server, postgres, redis, ML |
| `nextcloud-net` | bridge | nextcloud, postgres, redis |
| `monitoring-net` | external | Prometheus, Loki, Grafana, node-exporter, cAdvisor, Promtail, minecraft-exporter |

## Troubleshooting

```bash
# Service not reachable
docker ps | grep traefik
docker logs traefik

# Certificate issues
cat /srv/data/traefik/acme.json | jq '.["letsencrypt"]["Certificates"][]| .domain'

# Check backup logs
tail -f /var/log/backup_restic.log
tail -f /var/log/backup_postgres.log

# fail2ban status
sudo fail2ban-client status sshd
```

## License

MIT
