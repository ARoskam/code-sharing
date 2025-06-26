# XenServer Templates

This directory contains templates, pipeline definitions, and supporting files for automating the creation and configuration of Windows virtual machines on XenServer using Azure DevOps and Ansible.

## Structure
- `w11-24h2/` — Contains all files for building and configuring a Windows 11 24H2 template VM, including:
  - Pipeline YAML (`xenserver-w11-24H2-pipeline.yml`)
  - Ansible playbooks for VM creation and post-install configuration
  - Layered configuration playbooks and variable files in `build/`
  - Dynamic inventory files

## Main Actions
- Automates the deployment of Windows 11 24H2 VMs on XenServer
- Installs dependencies and pulls secrets securely
- Creates VMs from templates and attaches ISOs
- Waits for DNS and WinRM availability
- Runs post-install and layered configuration steps via Ansible

## Usage
Run the pipeline in Azure DevOps to provision and configure Windows VMs on XenServer with minimal manual intervention.

See the `w11-24h2/readme.md` for more details on the specific pipeline and playbooks in that subfolder.
