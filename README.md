# Home-setup
Home setup for Immich + Nextcloud

## Architecture
/srv/
├── docker/
│ ├── traefik/
│ │ ├── docker-compose.yml
│ │ └── traefik.yml
│ │
│ ├── immich/
│ │ ├── docker-compose.yml
│ │ ├── .env
│ │ └── library/
│ │
│ ├── nextcloud/
│ │ ├── docker-compose.yml
│ │ ├── .env
│ │ └── data/
│ │
│ └── backups/
│ ├── restic.sh
│ └── postgres-dumps/
│
└── compose/
└── docker-networks.yml

# TODO
- [ ] Add Immich backup
- [ ] Add nextcloud storage to hdd
- [ ] Add Nextcloud backup
- [ ] Add reverse proxy ssl and security headers
- [ ] Add Immich and Nextcloud to monitoring
