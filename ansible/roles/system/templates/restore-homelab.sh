#!/bin/bash
set -euo pipefail

DATE=${1:-latest}

export RESTIC_REPOSITORY="/srv/backup/restic-repo"
export RESTIC_PASSWORD_FILE="/root/.restic-password"
export SNAPSHOT_IMMICH=""
export SNAPSHOT_NEXTCLOUD=""
export SNAPSHOT_N8N=""
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

  SNAPSHOT_N8N=$(restic snapshots --json \
    | jq -r '
        sort_by(.time)
        | reverse
        | .[]
        | select(.time | startswith("'"$DATE"'"))
        | select(.tags | index("n8n"))
        | .short_id
      ' \
    | head -n1)
fi

### Check snapshots and pg backup exists ###
if [ "$SNAPSHOT_IMMICH" = "" ] || [ "$SNAPSHOT_NEXTCLOUD" = "" ] || [ "$SNAPSHOT_N8N" = "" ]; then
  echo "❌ No restic snapshot found for date $DATE"
  exit 1
fi

if [ ! -d "$PG_BASE" ]; then
  echo "❌ PostgreSQL backup directory not found: $PG_BASE"
  exit 1
fi

echo "Using immich restic snapshot:    $SNAPSHOT_IMMICH"
echo "Using nextcloud restic snapshot: $SNAPSHOT_NEXTCLOUD"
echo "Using n8n restic snapshot:       $SNAPSHOT_N8N"
echo "Using PostgreSQL backup:         $PG_BASE"

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
docker compose -f /opt/docker/n8n/docker-compose.yml down

echo "Waiting for services to stop..."
sleep 10

### 1.5 Clear data directories ###
rm -rf /srv/data/postgres/immich/*
rm -rf /srv/data/postgres/nextcloud/*
rm -rf /srv/data/n8n/*

### 2. Restore files ###
restic restore "$SNAPSHOT_IMMICH" \
  --target / \
  --path /srv/data/immich

restic restore "$SNAPSHOT_NEXTCLOUD" \
  --target / \
  --path /srv/data/nextcloud

restic restore "$SNAPSHOT_N8N" \
  --target / \
  --path /srv/data/n8n

### 3. Start PostgreSQL only ###
docker compose -f /opt/docker/immich/docker-compose.yml create
docker start immich-postgres

docker compose -f /opt/docker/nextcloud/docker-compose.yml create
docker start nextcloud-postgres

echo "Waiting for services to start..."
sleep 10

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
docker compose -f /opt/docker/n8n/docker-compose.yml up -d

echo "=== ✅ RESTORE COMPLETED ($DATE) ==="

