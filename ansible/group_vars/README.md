# Group_vars configuration

This directory contains variable files for different host groups used in the Ansible playbooks. These variable files allow you to define specific settings and configurations that can be applied to groups of hosts during playbook execution.

## Requirements
Ansible installed on the machine if you want to manage password-protected variables in this directory. <br>
To install Ansible, use the following command:
  
    sudo apt install ansible-core

## Usage
When running Ansible playbooks, the variables defined in these files will be automatically applied to the hosts that belong to the corresponding groups. This allows for flexible and reusable configurations across different environments or host types.

Password and sensitive information can be securely managed using Ansible Vault, ensuring that sensitive data is encrypted and protected, when accessing, use the `--ask-vault-pass` option with the `ansible-playbook` command to prompt for the vault password.

To modify or add variables for a specific host group, simply edit the corresponding variable file in this directory. If you want to access or modify password protected variables:

    ansible-vault edit group_vars/<group_name>/vars.yml

> Replace `<group_name>` with the actual name of the host group you wish to edit.

## Directory Structure
- Each sub-directory in this directory corresponds to a host group defined in the Ansible inventory.
- Variable files within these sub-directories are typically named `vars.yml` or similar, and they contain key-value pairs that define the variables for that group.

## Additional Information
For more information on managing variables in Ansible, refer to the [Ansible documentation on variables](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html).