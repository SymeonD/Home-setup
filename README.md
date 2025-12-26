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
- [x] Add Immich backup
- [x] Add nextcloud storage to hdd
- [x] Add Nextcloud backup
- [ ] Add reverse proxy ssl and security headers
- [ ] Add Immich and Nextcloud to monitoring

Restore restic
sudo restic -r /mnt/backups/restic-repo restore <snapshot_id>:srv/data/immich --target /srv/data/immich

Restore postgres
docker exec -i immich-postgres pg_restore --username=immich --dbname=immich < /mnt/backups/postgres/<dump-date>/immich.dump
