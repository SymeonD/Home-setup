#!/bin/bash

BACKUP_DIR="/srv/backup/postgres/$(date +%F)"
mkdir -p "$BACKUP_DIR"

# Immich
docker exec -t immich-postgres pg_dumpall --clean --if-exists --username=immich | gzip > "$BACKUP_DIR/immich_dump.sql.gz"

# Nextcloud
docker exec -t nextcloud-postgres pg_dumpall --clean --if-exists --username=nc | gzip > "$BACKUP_DIR/nextcloud_dump.sql.gz"

# Nettoyage ancien backup +30 jours
find /srv/backup/postgres/ -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;