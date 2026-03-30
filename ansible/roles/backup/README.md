# Backup configuration role

This role is responsible for setting up a backup solution on the target hosts. It includes tasks such as installing necessary dependencies, configuring backup scripts, and ensuring that the backup service is running correctly.

## Requirements
Ansible installed on the machine where the playbooks will be executed. <br>
To install Ansible, use the following command:
  
    sudo apt install ansible-core

## Usage
This role will be executed as part of the main Ansible playbooks located in the parent directory.

## Directory Structure
Files included in this role, and their purpose:
- `tasks/`: Directory for storing any static files that need to be copied to the target hosts.
  - [`main.yml`](./tasks/main.yml): Contains the tasks to be executed for backup configuration, in order of execution. Ensures that the backup directory exists and is mounted, creates postgres and restic repositories, as well as cron jobs for both backup systems.

## Additional Information
For more information on deploying backup solutions and their configuration options, refer to the [Restic documentation](https://restic.readthedocs.io/en/stable/) and [PostgreSQL documentation](https://www.postgresql.org/docs/).