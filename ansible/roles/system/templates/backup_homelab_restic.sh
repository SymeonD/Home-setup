#!/bin/bash

export RESTIC_REPO=/srv/backup/restic-repo
export RESTIC_PASSWORD="{{ restic_password }}"

# Initialiser le repo si nécessaire
if [ ! -f "$RESTIC_REPO/config" ]; then
    restic init --repo $RESTIC_REPO
fi

# Immich uploads
nice -n 19 ionice -c2 -n7 restic backup --repo $RESTIC_REPO /srv/data/immich/ -v --tag immich

# Nextcloud data
nice -n 19 ionice -c2 -n7 restic backup --repo $RESTIC_REPO /srv/data/nextcloud/ -v --tag nextcloud

# Minecraft server data
nice -n 19 ionice -c2 -n7 restic backup --repo $RESTIC_REPO /srv/data/minecraft/ -v --tag minecraft

# Supprimer les snapshots vieux de plus de 30 jours
restic forget --repo $RESTIC_REPO --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --prune