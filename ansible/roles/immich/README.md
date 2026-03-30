# Immich configuration role

This role is responsible for deploying Immich, a self-hosted photo and video management solution, on the target hosts. It includes tasks such as installing necessary dependencies, configuring Docker Compose for Immich, and ensuring that the Immich service is running correctly.

## Requirements
Ansible installed on the machine where the playbooks will be executed. <br>
To install Ansible, use the following command:
  
    sudo apt install ansible-core

## Usage
This role will be executed as part of the main Ansible playbooks located in the parent directory.

## Directory Structure
Files included in this role, and their purpose:
- `tasks/`: Directory for storing any static files that need to be copied to the target hosts.
  - [`main.yml`](./tasks/main.yml): Contains the tasks to be executed for Immich configuration, in order of execution. Creates .env configuration with ansible variables and docker-compose file, then starts the Immich service.
- `files/`: Directory for storing any static files that need to be copied to the target hosts.
  - [`docker-compose.yml`](./files/docker-compose.yml): Docker Compose file for Immich, defining the Immich services, main and subservers and its configuration. Sets docker and data volumes, and environment variables, link to traefik network.

## Additional Information
For more information on deploying Immich and its configuration options, refer to the [Immich documentation](https://docs.immich.app/).