#!/bin/bash
set -euo pipefail

DATE=${1:-latest}

export RESTIC_REPOSITORY="/srv/backup/restic-repo"
export RESTIC_PASSWORD="{{ restic_password }}"
export SNAPSHOT_IMMICH=""
export SNAPSHOT_NEXTCLOUD=""

echo "=== RESTORE HOMELAB ($DATE) ==="

### 0. Resolve restic snapshot ###
if [ "$DATE" = "latest" ]; then
  echo "Please specify a date for restore. Usage: $0 YYYY-MM-DD"
  exit 1
else
  SNAPSHOT_IMMICH=$(restic snapshots --json \
    | jq -r ".[] | select(.time | startswith(\"$DATE\")) | select(.tags | index(\"immich\")) | .short_id" \
    | head -n1)

  SNAPSHOT_NEXTCLOUD=$(restic snapshots --json \
    | jq -r ".[] | select(.time | startswith(\"$DATE\")) | select(.tags | index(\"nextcloud\")) | .short_id" \
    | head -n1)

  if [ "$SNAPSHOT_IMMICH" = "" ] || [ "$SNAPSHOT_NEXTCLOUD" = "" ]; then
    echo "❌ No restic snapshot found for date $DATE"
    exit 1
  fi
fi

echo "Using immich restic snapshot: $SNAPSHOT_IMMICH"
echo "Using nextcloud restic snapshot: $SNAPSHOT_NEXTCLOUD"

echo ""
echo "⚠️  Are you sure you want to restore to $DATE?"
read -p "This will overwrite current data! (y/N): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Restore cancelled."
  exit 0
fi

### 1. Stop services ###
docker compose -f /opt/docker/immich/docker-compose.yml down
docker compose -f /opt/docker/nextcloud/docker-compose.yml down

### 2. Restore files ###
restic restore "$SNAPSHOT_IMMICH" \
  --target /srv/data/immich \
  --path /srv/data/immich

restic restore "$SNAPSHOT_NEXTCLOUD" \
  --target /srv/data/nextcloud \
  --path /srv/data/nextcloud

### 3. Start PostgreSQL only ###
docker compose -f /opt/docker/immich/docker-compose.yml up -d immich-postgres
docker compose -f /opt/docker/nextcloud/docker-compose.yml up -d nextcloud-postgres

sleep 3

### 4. Restore PostgreSQL ###
PG_BASE="/srv/backup/postgres/$DATE"

if [ ! -d "$PG_BASE" ]; then
  echo "❌ PostgreSQL backup directory not found: $PG_BASE"
  exit 1
fi

docker exec -i immich-postgres \
  pg_restore --username=immich --dbname=immich < "$PG_BASE/immich.dump"

docker exec -i nextcloud-postgres \
  pg_restore --username=nc --dbname=nextcloud < "$PG_BASE/nextcloud.dump"

### 5. Restart all ###
docker compose -f /opt/docker/traefik/docker-compose.yml up -d
docker compose -f /opt/docker/immich/docker-compose.yml up -d
docker compose -f /opt/docker/nextcloud/docker-compose.yml up -d

echo "✅ Restore completed to $DATE"
