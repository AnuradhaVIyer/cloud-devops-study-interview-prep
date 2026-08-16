# Cloud DevOps Study & Interview Prep

This repository is a hands-on study guide for cloud and DevOps interview preparation. It is designed to help you practice core infrastructure concepts by creating, configuring, and securing real services with scripts, notes, and repeatable examples.

The repo starts with AWS core services using both PowerShell and Bash shell scripts. The same pattern will be expanded across Azure, GCP, Linux, automation, containers, orchestration, observability, and security topics.

## Study Areas

| Folder | Focus |
| --- | --- |
| `aws/` | AWS core services, IAM, VPC, EC2, S3, and cloud infrastructure fundamentals. |
| `azure/` | Azure core services, identity, networking, compute, storage, and platform fundamentals. |
| `gcp/` | Google Cloud core services, IAM, VPC networking, compute, storage, and platform fundamentals. |
| `linux-bash-shell/` | Linux commands, Bash scripting, permissions, processes, networking, and troubleshooting. |
| `git-github/` | Git workflows, branching, pull requests, GitHub usage, and collaboration practices. |
| `terraform/` | Infrastructure as Code concepts, providers, modules, state, variables, and reusable environments. |
| `ansible/` | Configuration management, inventories, playbooks, roles, and automation workflows. |
| `docker/` | Container basics, Dockerfiles, images, volumes, networking, and Compose. |
| `kubernetes/` | Kubernetes architecture, pods, deployments, services, ingress, config, secrets, and troubleshooting. |
| `observability/` | Logging, metrics, tracing, dashboards, alerts, and incident investigation. |
| `security-compliance/` | Cloud security, IAM best practices, encryption, governance, compliance, and audit readiness. |

> Some folders are planned and may be added as the study guide grows.

## Current AWS Scripts

The `aws/` folder contains paired PowerShell and Bash scripts for creating and practicing with AWS services:

| Step | PowerShell | Bash |
| --- | --- | --- |
| 1 | `aws-step1-create-user.ps1` | `aws-step1-create-user.sh` |
| 2 | `aws-step2-setup-vpc.ps1` | `aws-step2-setup-vpc.sh` |
| 3 | `aws-step3-launch-ubuntu-ec2.ps1` | `aws-step3-launch-ubuntu-ec2.sh` |
| 3 | `aws-step3-launch-windows-ec2.ps1` | `aws-step3-launch-windows-ec2.sh` |
| 4 | `aws-step4-secure-s3.ps1` | `aws-step4-secure-s3.sh` |

These scripts are intended to support interview prep by connecting theory to practical command-line work.

## How To Use This Repo

1. Pick a topic folder.
2. Read the scripts and notes for the service or tool you want to practice.
3. Run the PowerShell or Bash version depending on your environment.
4. Review what was created in the cloud console or CLI.
5. Practice explaining the purpose, architecture, security considerations, and troubleshooting steps.
6. Clean up resources when you are done practicing.

## Prerequisites

Depending on the topic, you may need:

- A cloud provider account such as AWS, Azure, or GCP.
- The provider CLI installed and configured.
- PowerShell for `.ps1` scripts.
- Bash shell for `.sh` scripts.
- Git and GitHub access.
- Local tools such as Terraform, Ansible, Docker, and Kubernetes CLI utilities as the repo expands.

## Interview Prep Goals

This guide is meant to help you build confidence with:

- Core cloud services and architecture decisions.
- Hands-on scripting and automation.
- Infrastructure as Code and configuration management.
- Containers and Kubernetes fundamentals.
- Linux and shell troubleshooting.
- Git/GitHub workflows used by DevOps teams.
- Observability, monitoring, logging, and alerting concepts.
- Security, compliance, IAM, and cloud governance basics.

## Safety Notes

- Review every script before running it.
- Confirm the target account, subscription, project, and region.
- Avoid committing secrets, access keys, passwords, private keys, or account-specific sensitive values.
- Clean up cloud resources after practice to avoid unexpected costs.

## Repo Status

This is an active learning repository. The AWS section is the starting point, and additional folders and examples will be added over time for Azure, GCP, Linux/Bash, Git/GitHub, Terraform, Ansible, Docker, Kubernetes, Observability, and Security/Compliance.
