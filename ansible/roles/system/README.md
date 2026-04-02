# System configuration role

This role is responsible for configuring system-level settings and commands on the target hosts. It includes tasks such as updating the system, installing essential packages, configuring system services, and applying security settings.

## Requirements
Ansible installed on the machine where the playbooks will be executed. <br>
To install Ansible, use the following command:
  
    sudo apt install ansible-core

## Usage
This role will be executed as part of the main Ansible playbooks located in the parent directory.

## Directory Structure
Files included in this role, and their purpose:
- `tasks/`: Directory for storing any static files that need to be copied to the target hosts.
  - [`main.yml`](./tasks/main.yml): Contains the tasks to be executed for system configuration, in order of execution.
  - [`timezone.yml`](./tasks/timezone.yml): Sets the system timezone.
  - [`packages.yml`](./tasks/packages.yml): Installs essential base packages, needed for system operation.
  - [`firewall.yml`](./tasks/firewall.yml): Configures the system firewall using UFW.
  - [`bashrc.yml`](./tasks/bashrc.yml): Deploys a custom .bashrc file with scripts for user convenience. Deploys `.bashrc`.
  - [`services.yml`](./tasks/services.yml): Install scripts to manage system services, including backup commands. Deploys `backup_homelab_postgres.sh`, `backup_homelab_restic.sh`, `start-homelab.sh`, `stop-homelab.sh` and `restore-homelab.sh`. All service management scripts use `kubectl` to interact with K3s.
  - [`swap.yml`](./tasks/swap.yml): Configures swap space on the system. Change value in `group_vars/all/vars.yml` to set swap size.
- `files/`: Directory for storing any static files that need to be copied to the target hosts.
  - [`.bashrc`](./files/.bashrc): Custom bashrc file with user convenience scripts. including `ll`, `la`, `l` and colored `grep`.
  - [`backup_homelab_postgres.sh`](./files/backup_homelab_postgres.sh): Script to backup all Postgres databases used in the homelab. Modify when services are added or removed. By default backs up `/srv/data/postgres/<service>` to `/srv/backup/postgres/<service>`.
  - [`start-homelab.sh`](./files/start-homelab.sh): Script to start all homelab services by scaling K3s deployments to 1 replica.
  - [`stop-homelab.sh`](./files/stop-homelab.sh): Script to stop all homelab services by scaling K3s deployments to 0 replicas.
- `templates/`: Directory for storing Jinja2 templates that can be rendered and deployed to the target hosts. Needed when configuration files require ansible variable substitution.
  - [`backup_homelab_restic.sh`](./templates/backup_homelab_restic.sh): Script to backup specified directories using Restic. Modify the source directories and repository settings as needed. By default backs up `/srv/data/<service>` to `/srv/backup/restic-repo/` using restic tags `--<service>`.
  - [`restore-homelab.sh`](./files/restore-homelab.sh): Script to restore data from backups for all homelab services. Uses `kubectl scale` to stop/start services and `kubectl exec` to restore PostgreSQL dumps. By default restores `/srv/backup/postgres/<service>` to `/srv/data/postgres/<service>` and `/srv/backup/restic-repo/` with tag `--<service>` to `/srv/data/<service>`.