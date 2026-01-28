#!/bin/bash

BACKUP_DIR="/srv/backup/postgres/$(date +%F)"
mkdir -p "$BACKUP_DIR"

docker exec immich-postgres pg_dump -Fc -U immich immich > "$BACKUP_DIR/immich.dump"
docker exec nextcloud-postgres pg_dump -Fc -U nc nextcloud > "$BACKUP_DIR/nextcloud.dump"

# Nettoyage ancien backup
find /srv/backup/postgres/ -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;