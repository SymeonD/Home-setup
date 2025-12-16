#!/bin/bash
export RESTIC_REPOSITORY=/mnt/backups/restic
export RESTIC_PASSWORD=supersecret


restic backup /srv/docker
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 2 --prune
