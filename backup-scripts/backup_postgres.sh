#!/bin/bash

BACKUP_DIR="/mnt/backups/postgres/$(date +%F)"
mkdir -p "$BACKUP_DIR"

docker exec immich-postgres pg_dump -U immich immich > "$BACKUP_DIR/immich.sql"
docker exec nextcloud-postgres pg_dump -U nc nextcloud > "$BACKUP_DIR/nextcloud.sql"

# Nettoyage ancien backup
find /mnt/backups/postgres/ -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;
