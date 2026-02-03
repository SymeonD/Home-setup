# Roles configuration

This directory contains Ansible roles that encapsulate specific configurations, tasks, and handlers. Roles allow for modular and reusable code, making it easier to manage complex playbooks by breaking them down into smaller, manageable components.

## Requirements
Ansible installed on the machine where the playbooks will be executed. <br>
To install Ansible, use the following command:
  
    sudo apt install ansible-core

## Usage
These roles will be executed as part of the main Ansible playbooks located in the parent directory. Each role can be included in a playbook to apply its specific configurations and tasks to the target hosts.

To view or modify a specific role, navigate to its sub-directory within this `roles/` directory. Each role typically contains the following structure:
```roles/
  └── <role_name>/
      ├── tasks/
      │   └── main.yml
      ├── files/
      └── templates/
```

## Directory Structure
Each sub-directory in this directory corresponds to a specific Ansible role. List of roles included, in order of execution:
- [`system/`](./system/README.md): Role for configuring system-level settings and commands. Click to view details.
- [`storage/`](./storage/README.md): Role for setting up storage configurations, external drives and logical volumes. Click to view details.
- [`docker/`](./docker/README.md): Role for installing and configuring Docker and Docker Compose. Click to view details.
- [`traefik/`](./traefik/README.md): Role for setting up Traefik as a reverse proxy, installs docker files and configuration. Click to view details.
- [`immich/`](./immich/README.md): Role for deploying Immich, a self-hosted photo and video management solution, installs docker files and configuration. Click to view details.
- [`nextcloud/`](./nextcloud/README.md): Role for deploying Nextcloud, a self-hosted cloud storage solution, installs docker files and configuration. Click to view details.
- [`backup/`](./backup/README.md): Role for setting up backup solutions, postgres dump and restic. Creates script for automated backups and restore. Click to view details.

## Additional Information
For more information on creating and managing Ansible roles, refer to the [Ansible documentation on roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html).