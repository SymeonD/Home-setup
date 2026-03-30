# Home-setup

Automated homelab setup using Ansible for deploying and managing containerized services (Traefik, Immich, Nextcloud) with backup and monitoring capabilities.

## Overview

This project provides a complete, reproducible Ansible configuration for setting up a personal homelab with:

- **Traefik**: Reverse proxy with automatic SSL/TLS via Let's Encrypt
- **Immich**: Self-hosted photo management and backup system
- **Nextcloud**: Self-hosted file storage and collaboration platform
- **Monitoring**: Prometheus & Grafana for system and application monitoring
- **Backup**: Automated backups using Restic and PostgreSQL dumps
- **Storage**: LVM-based volume management with flexible backup strategy

## Quick Start

### Prerequisites

- Ansible 2.17+ installed on the control machine
- SSH access to your homelab server
- Vault password for encrypted variables

### Installation

```bash
# Clone the repository
git clone https://github.com/SymeonD/Home-setup.git
cd Home-setup

# Run the playbook
ansible-playbook -i localhost, ansible/homelab.yml --ask-vault-pass
```

## Project Structure

```
Home-setup/
├── ansible/
│   ├── homelab.yml                 # Main playbook
│   ├── roles/                      # Ansible roles for each service
│   │   ├── system/                 # System setup (packages, firewall, timezone)
│   │   ├── storage/                # LVM configuration
│   │   ├── docker/                 # Docker installation
│   │   ├── traefik/                # Reverse proxy & SSL management
│   │   ├── immich/                 # Photo management service
│   │   ├── nextcloud/              # File storage service
│   │   ├── minecraft/              # Minecraft server (optional)
│   │   ├── monitoring_collectors/  # Prometheus collectors
│   │   ├── prometheus/             # Metrics database
│   │   ├── grafana/                # Monitoring dashboard
│   │   └── backup/                 # Backup scripts
│   ├── group_vars/
│   │   └── all/
│   │       ├── all.yml             # General variables
│   │       └── vault.yml           # Encrypted secrets (Ansible Vault)
│   └── inventory                   # Host inventory

└── README.md                        # This file
```

## Configuration

All variables are centralized in `ansible/group_vars/all/`:
- **all.yml**: Public configuration (paths, timezone, domain references)
- **vault.yml**: Encrypted secrets (passwords, API keys, domain names)

To edit encrypted variables:
```bash
cd ansible
ansible-vault edit group_vars/all/vault.yml
```

## Storage Setup

The default LVM configuration expects:

**NVME/SSD:**
- 100GB for root (`/`)
- 100GB for Docker (`/var/lib/docker`)
- 750GB for application data (`/srv/data`)

**HDD (optional):**
- 500GB+ for backups (`/srv/backup`)

See [storage role documentation](./ansible/roles/storage/README.md) for detailed LVM setup.

## Services

### Traefik
Reverse proxy with automatic SSL certificate management via Let's Encrypt.
- **Dashboard**: Accessible at `https://traefik.<domain>`
- **Config**: [traefik role documentation](./ansible/roles/traefik/README.md)

### Immich
Self-hosted photo management with machine learning-powered features.
- **URL**: `https://immich.<domain>`
- **Database**: PostgreSQL (isolated)
- **Config**: [immich role documentation](./ansible/roles/immich/README.md)

### Nextcloud
Self-hosted file storage and collaboration suite.
- **URL**: `https://nextcloud.<domain>`
- **Database**: PostgreSQL (isolated)
- **Config**: [nextcloud role documentation](./ansible/roles/nextcloud/README.md)

### Monitoring
Prometheus + Grafana for system and application monitoring.
- **Grafana**: Accessible at `https://grafana.<domain>`
- **Prometheus**: Internal metrics endpoint
- **Collectors**: Configured via Loki, Promtail, and custom exporters

## Backup & Restore

### Automated Backups

Backups run on a daily schedule via cron:
- **Restic backups**: 2:00 AM daily (full filesystem snapshot)
- **PostgreSQL dumps**: 3:00 AM daily (database backups)

Location: `/srv/backup/`

### Manual Restore

**Restore from Restic snapshot:**
```bash
sudo restic -r /srv/backup/restic-repo restore <snapshot_id>:srv/data/immich --target /srv/data/immich
```

**Restore PostgreSQL database:**
```bash
docker exec -i immich-postgres pg_restore --username=postgres --dbname=immich < /srv/backup/postgres/<dump.dump>
```

See [backup role documentation](./ansible/roles/backup/README.md) for details.

## Networking

All services communicate through Docker networks:
- **traefik-net**: External network for reverse proxy routing
- **immich-net**: Internal network for Immich services
- **nextcloud-net**: Internal network for Nextcloud services
- **monitoring-net**: Internal network for monitoring stack

## Troubleshooting

### Cannot reach services
- Verify Traefik is running: `docker ps | grep traefik`
- Check Traefik logs: `docker logs traefik`
- Verify DNS resolution for your domain

### SSL certificate issues
- Check Let's Encrypt storage: `/srv/data/traefik/acme.json`
- Verify email configuration in vault variables
- See [traefik documentation](./ansible/roles/traefik/README.md)

### Service won't start
- Check Docker logs: `docker logs <service-name>`
- Verify volume mounts and permissions
- Check database connectivity

## Contributing

This is a personal homelab setup but contributions and improvements are welcome.

## License

MIT License - Feel free to use and modify for your own homelab setup.

## Security Notes

- Always use Ansible Vault for sensitive data (passwords, tokens, domain names)
- Keep your vault password secure
- Regularly review your firewall rules
- Monitor backup logs to ensure backups are completing successfully
