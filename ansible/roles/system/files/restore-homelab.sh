#!/bin/bash
set -euo pipefail

DATE=${1:-}
shift || true
REQUESTED=("$@")

usage() {
  echo "Usage: $0 YYYY-MM-DD [SERVICE...]"
  echo ""
  echo "  YYYY-MM-DD  Date of the backup to restore (required)"
  echo "  SERVICE...  One or more services to restore (optional, default: all)"
  echo ""
  echo "  Available services: immich  nextcloud  n8n  minecraft"
  echo ""
  echo "Examples:"
  echo "  $0 2024-01-15                        # Restore everything"
  echo "  $0 2024-01-15 immich                 # Restore immich only"
  echo "  $0 2024-01-15 nextcloud minecraft    # Restore two services"
}

if [ -z "$DATE" ]; then
  usage
  exit 1
fi

if [[ ! "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "❌ Invalid date format: '$DATE' (expected YYYY-MM-DD)"
  echo ""
  usage
  exit 1
fi

export RESTIC_REPOSITORY="/srv/backup/restic-repo"
export RESTIC_PASSWORD_FILE="/root/.restic-password"
export PG_BASE="/srv/backup/postgres/$DATE"

### Service definitions ###

declare -A SERVICE_TAG=(
  [immich]="immich"
  [nextcloud]="nextcloud"
  [n8n]="n8n"
  [minecraft]="minecraft"
)

declare -A SERVICE_COMPOSE=(
  [immich]="/opt/docker/immich/docker-compose.yml"
  [nextcloud]="/opt/docker/nextcloud/docker-compose.yml"
  [n8n]="/opt/docker/n8n/docker-compose.yml"
  [minecraft]="/opt/docker/minecraft/docker-compose.yml"
)

declare -A SERVICE_DATA=(
  [immich]="/srv/data/immich"
  [nextcloud]="/srv/data/nextcloud"
  [n8n]="/srv/data/n8n"
  [minecraft]="/srv/data/minecraft"
)

# PostgreSQL metadata (only for services that use it)
declare -A PG_CONTAINER=(
  [immich]="immich-postgres"
  [nextcloud]="nextcloud-postgres"
)
declare -A PG_DUMP=(
  [immich]="immich_dump.sql.gz"
  [nextcloud]="nextcloud_dump.sql.gz"
)
declare -A PG_DB=(
  [immich]="immich"
  [nextcloud]="nextcloud"
)
declare -A PG_USER=(
  [immich]="postgres"
  [nextcloud]="postgres"
)
declare -A PG_DATA_DIR=(
  [immich]="/srv/data/postgres/immich"
  [nextcloud]="/srv/data/postgres/nextcloud"
)

ALL_SERVICES=(immich nextcloud n8n minecraft)

### Determine which services to restore ###
if [ ${#REQUESTED[@]} -eq 0 ]; then
  SERVICES=("${ALL_SERVICES[@]}")
else
  SERVICES=()
  for svc in "${REQUESTED[@]}"; do
    if [[ ! " ${ALL_SERVICES[*]} " =~ " ${svc} " ]]; then
      echo "❌ Unknown service: $svc"
      echo "Valid services: ${ALL_SERVICES[*]}"
      exit 1
    fi
    SERVICES+=("$svc")
  done
fi

echo "=== RESTORE HOMELAB ($DATE) ==="
echo "Services: ${SERVICES[*]}"
echo ""

### Resolve restic snapshots ###
declare -A SNAPSHOT

for svc in "${SERVICES[@]}"; do
  tag="${SERVICE_TAG[$svc]}"
  snap=$(restic snapshots --json \
    | jq -r '
        sort_by(.time)
        | reverse
        | .[]
        | select(.time | startswith("'"$DATE"'"))
        | select(.tags | index("'"$tag"'"))
        | .short_id
      ' \
    | head -n1)

  if [ -z "$snap" ]; then
    echo "❌ No restic snapshot found for service '$svc' on date $DATE"
    exit 1
  fi

  SNAPSHOT[$svc]="$snap"
  echo "Using $svc restic snapshot:  ${SNAPSHOT[$svc]}"
done

### Check PostgreSQL dumps for services that need it ###
for svc in "${SERVICES[@]}"; do
  if [[ -n "${PG_DUMP[$svc]+_}" ]]; then
    dump_path="$PG_BASE/${PG_DUMP[$svc]}"
    if [ ! -f "$dump_path" ]; then
      echo "❌ PostgreSQL dump not found: $dump_path"
      exit 1
    fi
    echo "Using $svc PostgreSQL dump: $dump_path"
  fi
done

echo ""
echo "⚠️  Are you sure you want to restore [${SERVICES[*]}] to $DATE?"
read -p "This will overwrite current data! (y/N): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Restore cancelled."
  exit 0
fi

### 1. Stop services ###
for svc in "${SERVICES[@]}"; do
  echo "Stopping $svc..."
  docker compose -f "${SERVICE_COMPOSE[$svc]}" down -v
done

echo "Waiting for services to stop..."
sleep 10

### 1.5. Clear PostgreSQL data directories ###
for svc in "${SERVICES[@]}"; do
  if [[ -n "${PG_DATA_DIR[$svc]+_}" ]]; then
    echo "Clearing PostgreSQL data for $svc..."
    rm -rf "${PG_DATA_DIR[$svc]}"/*
  fi
done

### 2. Restore files via restic ###
for svc in "${SERVICES[@]}"; do
  echo "Restoring $svc files..."
  restic restore "${SNAPSHOT[$svc]}" \
    --target / \
    --path "${SERVICE_DATA[$svc]}"
done

### 3. Start PostgreSQL only (for services that need it) ###
PG_SERVICES=()
for svc in "${SERVICES[@]}"; do
  if [[ -n "${PG_CONTAINER[$svc]+_}" ]]; then
    PG_SERVICES+=("$svc")
  fi
done

if [ ${#PG_SERVICES[@]} -gt 0 ]; then
  for svc in "${PG_SERVICES[@]}"; do
    echo "Creating containers for $svc (postgres only)..."
    docker compose -f "${SERVICE_COMPOSE[$svc]}" create
    docker start "${PG_CONTAINER[$svc]}"
  done

  echo "Waiting for PostgreSQL to start..."
  sleep 10

  ### 4. Restore PostgreSQL ###
  for svc in "${PG_SERVICES[@]}"; do
    echo "Restoring PostgreSQL for $svc..."
    gunzip --stdout "$PG_BASE/${PG_DUMP[$svc]}" \
      | sed "s/SELECT pg_catalog.set_config('search_path', '', false);/SELECT pg_catalog.set_config('search_path', 'public, pg_catalog', true);/g" \
      | docker exec -i "${PG_CONTAINER[$svc]}" psql --dbname="${PG_DB[$svc]}" --username="${PG_USER[$svc]}"
  done
fi

### 5. Restart all restored services ###
docker compose -f /opt/docker/traefik/docker-compose.yml up -d

for svc in "${SERVICES[@]}"; do
  echo "Starting $svc..."
  docker compose -f "${SERVICE_COMPOSE[$svc]}" up -d
done

echo ""
echo "=== ✅ RESTORE COMPLETED ([${SERVICES[*]}] @ $DATE) ==="
