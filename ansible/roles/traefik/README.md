# Traefik configuration role

This role is responsible for setting up Traefik as a reverse proxy on the target hosts. It includes tasks such as installing Traefik, configuring it to work with Docker, and ensuring that it is running correctly.

## Requirements
Ansible installed on the machine where the playbooks will be executed. <br>
To install Ansible, use the following command:
  
    sudo apt install ansible-core

## Usage
This role will be executed as part of the main Ansible playbooks located in the parent directory

## Directory Structure
Files included in this role, and their purpose:
- `tasks/`: Directory for storing any static files that need to be copied to the target hosts.
  - [`main.yml`](./tasks/main.yml): Contains the tasks to be executed for Traefik configuration, in order of execution. Installs Traefik, creates ACME file and .env configuration.
- `files/`: Directory for storing any static files that need to be copied to the target hosts.
  - [`traefik.yml`](./files/traefik.yml): Traefik configuration file, defining entry points, providers, and other settings for Traefik. Configures Traefik to work with Docker and sets up the dashboard. Change certificate resolver settings to staging when running tests to avoid hitting Let's Encrypt rate limits.
  - [`docker-compose.yml`](./files/docker-compose.yml): Docker Compose file for Traefik, defining the Traefik service and its configuration. Sets docker and data volumes.

## Additional Information
For more information on deploying Traefik and its configuration options, refer to the [Traefik documentation](https://doc.traefik.io/traefik/).