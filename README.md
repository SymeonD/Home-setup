# Home-setup
Home setup for Immich + Nextcloud

# Use
ansible-playbook -i localhost, homelab.yml --ask-vault-pass --skip-tags init_backup


## Architecture
/srv/
├── docker/
│ └── traefik/
├── backup/
│ ├── immich/
│ └── nextcloud/
├── backup-scripts/
│ ├── backup_postgres.sh
│ └── backup_restic.sh
└── data/
  ├── immich/
  ├── nextcloud/
  ├── postgres/
  │ ├── immich/
  │ └── nextcloud/
  ├── redis/
  └── traefik/

# LVM Setup
nvme
100go - / 
100go - /var/lib/docker
750go - /srv/data
hdd
500go - /srv/backup (à mount)

# Aliases (bashrc)
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

HISTCONTROL=ignoreboth

HISTSIZE=1000
HISTFILESIZE=2000

# Backup
### Restic backup chaque jour à 2h
#0 2 * * * /srv/backup-scripts/backup_restic.sh >> /var/log/backup_restic.log 2>&1

### Postgres backup chaque jour à 3h
#0 3 * * * /srv/backup-scripts/backup_postgres.sh >> /var/log/backup_postgres.log 2>&1


# TODO
- [ ] Add homepage (github) dashboard
- [ ] Put back HDD as backup

Restore restic
sudo restic -r /mnt/backups/restic-repo restore <snapshot_id>:srv/data/immich --target /srv/data/immich

Restore postgres
docker exec -i immich-postgres pg_restore --username=immich --dbname=immich < /mnt/backups/postgres/<dump-date>/immich.dump

# Others
- Ansible NAS (github)
- N8n setup

# Steps to reproduce
- Create lv root as 100go when initializing system
- Setup LVM
- Install Docker & Docker-compose
- Setup Traefik
- Setup Immich
- Setup Nextcloud
- Setup Restic backup
- Setup Postgres backup
- Setup cron jobs
- Setup aliases and bashrc

# TODO for main
- Change docker-vg to ubuntu-vg (use default one, created by boot)
- Change ansible command, remove -i localhost
- Change ansible host to localhost, connection local
- Change to include tasks for backup
- Docker change ansible use to ansible user id
- README add --skip-tags to ansible start command
- Remove external in traefik ansible
- Change immich file to docker root for .env


Check volumes immich and nextcloud