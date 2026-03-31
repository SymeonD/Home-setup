#!/bin/bash
set -uo pipefail

REQUESTED=("$@")

export RESTIC_REPOSITORY=/srv/backup/restic-repo
export RESTIC_PASSWORD_FILE=/root/.restic-password

### Service definitions ###

declare -A SERVICE_TAG=(
  [immich]="immich"
  [nextcloud]="nextcloud"
  [n8n]="n8n"
  [minecraft]="minecraft"
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
declare -A PG_DUMP_FILE=(
  [immich]="immich_dump.sql.gz"
  [nextcloud]="nextcloud_dump.sql.gz"
)
declare -A PG_USER=(
  [immich]="postgres"
  [nextcloud]="postgres"
)

ALL_SERVICES=(immich nextcloud n8n minecraft)

### Determine which services to back up ###
if [ ${#REQUESTED[@]} -eq 0 ]; then
  SERVICES=("${ALL_SERVICES[@]}")
else
  SERVICES=()
  for svc in "${REQUESTED[@]}"; do
    if [[ ! " ${ALL_SERVICES[*]} " =~ " ${svc} " ]]; then
      echo "❌ Unknown service: '$svc'"
      echo ""
      echo "Available services: ${ALL_SERVICES[*]}"
      echo "Usage: $0 [SERVICE...]"
      exit 1
    fi
    SERVICES+=("$svc")
  done
fi

DATE=$(date +%F)
BACKUP_DIR="/srv/backup/postgres/$DATE"

echo "=== BACKUP HOMELAB ($DATE) ==="
echo "Services: ${SERVICES[*]}"
echo ""

FAILED_SERVICES=()

### Per-service backup ###
for svc in "${SERVICES[@]}"; do
  echo "--- [$svc] Starting backup ---"
  svc_failed=false

  # PostgreSQL dump (if applicable)
  if [[ -n "${PG_CONTAINER[$svc]+_}" ]]; then
    echo "[$svc] Dumping PostgreSQL..."
    mkdir -p "$BACKUP_DIR"
    if docker exec "${PG_CONTAINER[$svc]}" \
        pg_dumpall --clean --if-exists --username="${PG_USER[$svc]}" \
        | gzip > "$BACKUP_DIR/${PG_DUMP_FILE[$svc]}"; then
      echo "[$svc] PostgreSQL dump saved to $BACKUP_DIR/${PG_DUMP_FILE[$svc]}"
    else
      echo "❌ [$svc] PostgreSQL dump failed — skipping restic backup for this service"
      FAILED_SERVICES+=("$svc")
      svc_failed=true
    fi
  fi

  # Restic file backup
  if [ "$svc_failed" = false ]; then
    echo "[$svc] Running restic backup..."
    if nice -n 19 ionice -c2 -n7 restic backup "${SERVICE_DATA[$svc]}/" \
        -v --tag "${SERVICE_TAG[$svc]}"; then
      echo "✅ [$svc] Backup completed"
    else
      echo "❌ [$svc] Restic backup failed"
      FAILED_SERVICES+=("$svc")
    fi
  fi

  echo ""
done

### Retention policy (only when backing up all services) ###
if [ ${#REQUESTED[@]} -eq 0 ]; then
  echo "Applying retention policy..."
  restic forget \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 12 \
    --prune \
    --max-unused 5%
fi

### Cleanup old PostgreSQL dumps (only when backing up all services) ###
if [ ${#REQUESTED[@]} -eq 0 ]; then
  echo "Cleaning up PostgreSQL dumps older than 30 days..."
  find /srv/backup/postgres/ -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;
fi

echo ""
if [ ${#FAILED_SERVICES[@]} -gt 0 ]; then
  echo "=== ⚠️  BACKUP COMPLETED WITH ERRORS ==="
  echo "Failed services: ${FAILED_SERVICES[*]}"
  exit 1
else
  echo "=== ✅ BACKUP COMPLETED ([${SERVICES[*]}] @ $DATE) ==="
fi
