#!/bin/bash

export RESTIC_REPOSITORY=/mnt/backups/restic-repo
export RESTIC_PASSWORD="grouille123"

# Immich uploads
restic backup /srv/data/immich/ -v --tag immich

# Nextcloud data
restic backup /srv/data/nextcloud/ -v --tag nextcloud

# Supprimer les snapshots vieux de plus de 30 jours
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --prune
