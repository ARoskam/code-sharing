# XenServer Windows 11 24H2 Template Pipeline

This folder contains the pipeline and playbooks for building and configuring a Windows 11 24H2 template on XenServer using Azure DevOps and Ansible.

## Pipeline Actions

The `xenserver-w11-24H2-pipeline.yml` file automates the following steps:

1. **Install Dependencies**
   - Installs Python, Ansible, and required collections on the build agent.

2. **Pull Secrets**
   - Retrieves sensitive variables (admin passwords, share credentials) from HashiCorp Vault and sets them as pipeline variables.

3. **Create XenServer VM**
   - Runs `vm-build.yml` to create a new Windows 11 VM from a template on XenServer, attach ISOs, and configure storage/networking.

4. **Post-Install Actions**
   - Runs `postinstall.yml` to:
     - Wait for DNS and WinRM to become available on the new VM.
     - Generate a dynamic Ansible inventory for the VM.
     - Run post-install configuration tasks on the VM via WinRM.

5. **Layered Configuration**
   - Runs modular playbooks in `build/` for staged configuration:
     - `P1-OSconfig-Updates.yml`: OS configuration and updates.
     - `P2-Install-Apps.yml`: Application installation and further setup.

## Folder Structure
- `xenserver-w11-24H2-pipeline.yml` — Azure DevOps pipeline definition
- `vm-build.yml` — Ansible playbook to create the VM
- `postinstall.yml` — Ansible playbook for post-install configuration
- `inventory.ini` — Ansible inventory (generated/used by playbooks)
- `build/` — Layered configuration playbooks and variable files

## Usage
Run the pipeline in Azure DevOps to fully automate the creation and configuration of a Windows 11 24H2 template VM on XenServer.
