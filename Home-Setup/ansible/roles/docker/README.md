# Docker configuration role

This role is responsible for installing and configuring Docker and Docker Compose on the target hosts. It includes tasks such as installing Docker packages, setting up user permissions, and ensuring that Docker services are running correctly.

## Requirements
Ansible installed on the machine where the playbooks will be executed. <br>
To install Ansible, use the following command:
  
    sudo apt install ansible-core

## Usage
This role will be executed as part of the main Ansible playbooks located in the parent directory.

## Directory Structure
Files included in this role, and their purpose:
- `tasks/`: Directory for storing any static files that need to be copied to the target hosts.
  - [`main.yml`](./tasks/main.yml): Installs and configures Docker and Docker Compose, starts the service and ensure it is enabled on boot.