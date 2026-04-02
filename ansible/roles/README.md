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
- [`k3s/`](./k3s/README.md): Role for installing and configuring K3s and deploying Kubernetes namespaces and network policies. Click to view details.
- [`traefik_k8s/`](./traefik_k8s/README.md): Role for deploying Traefik as a reverse proxy on K3s. Click to view details.
- [`immich_k8s/`](./immich_k8s/README.md): Role for deploying Immich on K3s. Click to view details.
- [`nextcloud_k8s/`](./nextcloud_k8s/README.md): Role for deploying Nextcloud on K3s. Click to view details.
- [`n8n_k8s/`](./n8n_k8s/README.md): Role for deploying n8n on K3s. Click to view details.
- [`minecraft_k8s/`](./minecraft_k8s/README.md): Role for deploying Minecraft server on K3s. Click to view details.
- [`monitoring_k8s/`](./monitoring_k8s/README.md): Role for deploying the monitoring stack (Prometheus, Grafana, Loki, Promtail, cAdvisor, node-exporter) on K3s. Click to view details.
- [`backup/`](./backup/README.md): Role for setting up backup solutions, postgres dump and restic. Creates script for automated backups and restore. Click to view details.

## Additional Information
For more information on creating and managing Ansible roles, refer to the [Ansible documentation on roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html).