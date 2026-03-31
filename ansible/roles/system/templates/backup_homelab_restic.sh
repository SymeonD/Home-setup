#!/bin/bash

export RESTIC_REPOSITORY=/srv/backup/restic-repo
export RESTIC_PASSWORD_FILE=/root/.restic-password

# Immich uploads
nice -n 19 ionice -c2 -n7 restic backup /srv/data/immich/ -v --tag immich

# Nextcloud data
nice -n 19 ionice -c2 -n7 restic backup /srv/data/nextcloud/ -v --tag nextcloud

# Minecraft server data
nice -n 19 ionice -c2 -n7 restic backup /srv/data/minecraft/ -v --tag minecraft

# n8n workflows and credentials
nice -n 19 ionice -c2 -n7 restic backup /srv/data/n8n/ -v --tag n8n

# Retention policy
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --prune