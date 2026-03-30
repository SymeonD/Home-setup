# Storage configuration role

This role is responsible for setting up storage configurations on the target hosts. It includes tasks such as configuring external drives, setting up logical volumes, and ensuring proper mount points for data storage.

## Requirements
Ansible installed on the machine where the playbooks will be executed. <br>
To install Ansible, use the following command:
  
    sudo apt install ansible-core

## Usage
This role will be executed as part of the main Ansible playbooks located in the parent directory.

## Directory Structure
Files included in this role, and their purpose:
- `tasks/`: Directory for storing any static files that need to be copied to the target hosts.
  - [`main.yml`](./tasks/main.yml): Contains the tasks to be executed for storage configuration, in order of execution.
  - [`lvm.yml`](./tasks/lvm.yml): Sets up Logical Volume Management (LVM) for flexible disk management, for ubuntu, data and backup. Size are defined here.
  - [`backup.yml`](./tasks/backup.yml): Configures backup storage, including setting up directories and permissions for backup data, vg and lv.
  - [`mounts.yml`](./tasks/mounts.yml): Configures mount points for backup data storage, ensuring that the appropriate directories are mounted at boot and have the correct permissions, set it permanently in `/etc/fstab`.
