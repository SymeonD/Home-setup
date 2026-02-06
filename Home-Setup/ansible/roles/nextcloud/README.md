# Nextcloud configuration role

This role is responsible for deploying Nextcloud, a self-hosted cloud storage solution, on the target hosts. It includes tasks such as installing necessary dependencies, configuring Docker Compose for Nextcloud, and ensuring that the Nextcloud service is running correctly.

## Requirements
Ansible installed on the machine where the playbooks will be executed. <br>
To install Ansible, use the following command:
  
    sudo apt install ansible-core

## Usage
This role will be executed as part of the main Ansible playbooks located in the parent directory.

## Directory Structure
Files included in this role, and their purpose:
- `tasks/`: Directory for storing any static files that need to be copied to the target hosts.
  - [`main.yml`](./tasks/main.yml): Contains the tasks to be executed for Nextcloud configuration, in order of execution. Creates .env configuration with ansible variables, config.php file and reverse proxy configuration; docker-compose file, then starts the Nextcloud service.
- `files/`: Directory for storing any static files that need to be copied to the target hosts.
  - [`docker-compose.yml`](./files/docker-compose.yml): Docker Compose file for Nextcloud, defining the Nextcloud and database services and their configuration. Sets docker and data volumes, and environment variables, link to traefik network.

## Additional Information
For more information on deploying Nextcloud and its configuration options, refer to the [Nextcloud documentation](https://docs.nextcloud.com/).