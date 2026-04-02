# Ansible configuration

This directory contains Ansible playbooks and configuration files used for automating the setup and management of systems.


## Requirements

Ansible installed on the machine where the playbooks will be executed. <br>
Command:
  
    sudo apt install ansible-core


## Usage

To run the Ansible playbooks, navigate to this directory and execute the desired playbook using the following command:

    ansible-playbook homelab.yml --ask-vault-pass --ask-become

> The `--ask-vault-pass` flag prompts for the Ansible Vault password if encrypted variables are used, and the `--ask-become` flag prompts for privilege escalation (sudo) password if required.

Ensure that you have the necessary inventory file and configuration settings in place before executing the playbooks.

## Directory Structure
- `homelab.yml`: Main Ansible playbook for setting up the homelab environment.
- [`group_vars/`](./group_vars/README.md): Directory containing variable files for different host groups. Click to view details.
- [`roles/`](./roles/README.md): Directory containing Ansible roles that encapsulate specific configurations and tasks. Click to view details.

## Additional Information

For more information on how to create and manage Ansible playbooks, refer to the [Ansible documentation](https://docs.ansible.com/).

## TODO:
- [ ] Add snapshots date listing in restore script when nothing is found
- [ ] Add echo to backup scripts
- [x] Clean repo
- [x] Migrate from Docker Compose to K3s