#!/bin/bash
set -euo pipefail

DATE=${1:-latest}

export RESTIC_REPOSITORY="/srv/backup/restic-repo"
export RESTIC_PASSWORD="{{ restic_password }}"
export SNAPSHOT_IMMICH=""
export SNAPSHOT_NEXTCLOUD=""
export PG_BASE="/srv/backup/postgres/$DATE"

echo "=== RESTORE HOMELAB ($DATE) ==="

### 0. Resolve restic snapshot ###
if [ "$DATE" = "latest" ]; then
  echo "Please specify a date for restore. Usage: $0 YYYY-MM-DD"
  exit 1
else
  SNAPSHOT_IMMICH=$(restic snapshots --json \
  | jq -r '
      sort_by(.time)
      | reverse
      | .[]
      | select(.time | startswith("'"$DATE"'"))
      | select(.tags | index("immich"))
      | .short_id
    ' \
  | head -n1)

  SNAPSHOT_NEXTCLOUD=$(restic snapshots --json \
    | jq -r '
        sort_by(.time)
        | reverse
        | .[]
        | select(.time | startswith("'"$DATE"'"))
        | select(.tags | index("nextcloud"))
        | .short_id
      ' \
    | head -n1)
fi

### Check snapshots and pg backup exists ###
if [ "$SNAPSHOT_IMMICH" = "" ] || [ "$SNAPSHOT_NEXTCLOUD" = "" ]; then
echo "❌ No restic snapshot found for date $DATE"
exit 1
fi

if [ ! -d "$PG_BASE" ]; then
  echo "❌ PostgreSQL backup directory not found: $PG_BASE"
  exit 1
fi

echo "Using immich restic snapshot: $SNAPSHOT_IMMICH"
echo "Using nextcloud restic snapshot: $SNAPSHOT_NEXTCLOUD"
echo "Using PostgreSQL backup: $PG_BASE"

echo ""
echo "⚠️  Are you sure you want to restore to $DATE?"
read -p "This will overwrite current data! (y/N): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Restore cancelled."
  exit 0
fi

### 1. Stop services ###
docker compose -f /opt/docker/immich/docker-compose.yml down -v
docker compose -f /opt/docker/nextcloud/docker-compose.yml down -v

echo "Waiting for services to stop..."
sleep 10

### 1.5 Clear data directories ###
rm -rf /srv/data/postgres/immich/*
rm -rf /srv/data/postgres/nextcloud/*

### 2. Restore files ###
restic restore "$SNAPSHOT_IMMICH" \
  --target /srv/data/immich \
  --path /srv/data/immich

restic restore "$SNAPSHOT_NEXTCLOUD" \
  --target /srv/data/nextcloud \
  --path /srv/data/nextcloud

### 3. Start PostgreSQL only ###
docker compose -f /opt/docker/immich/docker-compose.yml create
docker start immich-postgres

docker compose -f /opt/docker/nextcloud/docker-compose.yml create
docker start nextcloud-postgres

echo "Waiting for services to start..."
sleep 3

### 4. Restore PostgreSQL ###
gunzip --stdout "$PG_BASE/immich_dump.sql.gz" \
| sed "s/SELECT pg_catalog.set_config('search_path', '', false);/SELECT pg_catalog.set_config('search_path', 'public, pg_catalog', true);/g" \
| docker exec -i immich-postgres psql --dbname=immich --username=postgres  # Restore Backup

gunzip --stdout "$PG_BASE/nextcloud_dump.sql.gz" \
| sed "s/SELECT pg_catalog.set_config('search_path', '', false);/SELECT pg_catalog.set_config('search_path', 'public, pg_catalog', true);/g" \
| docker exec -i nextcloud-postgres psql --dbname=nextcloud --username=postgres  # Restore Backup

### 5. Restart all ###
docker compose -f /opt/docker/traefik/docker-compose.yml up -d
docker compose -f /opt/docker/immich/docker-compose.yml up -d
docker compose -f /opt/docker/nextcloud/docker-compose.yml up -d

echo "=== ✅ RESTORE COMPLETED ($DATE) ==="

