# CloudHER Cohort 1 — Cloud DevOps Portfolio

## Background

My path into cloud and DevOps began with hands-on training through the AWS re/Start 
program and the DevOps Micro Internship (DMI), where I built a strong technical 
foundation in cloud infrastructure and automation. Despite this preparation, translating 
that foundation into a successful return to the workforce proved difficult on my own.

Joining CloudHER Cohort 1 gave me the structured mentorship and accountability I needed 
to close that gap. This repository reflects that journey — a hands-on study guide built 
during the program, where I practiced core infrastructure concepts by creating, 
configuring, and securing real services through scripts, notes, and repeatable examples.

The repo starts with AWS core services using both PowerShell and Bash shell scripts. The same pattern will be expanded across Azure, GCP, Linux, automation, containers, orchestration, observability, and security topics.

## CloudHER Cohort 1 — Week 12 Output

*Mentor: Obiora Okoye, CloudHER Cohort 1*

### How This Repo Came to Be

I joined CloudHER Cohort 1 while re-entering the tech industry after a career break. 
In our early sessions, Obiora and I focused first on positioning — reworking my resume 
and LinkedIn profile so they clearly communicated the value I could bring, not just a 
list of past titles and tools.

From there, the conversation shifted to a gap I hadn't fully named myself: courses and 
certifications alone weren't enough. What I needed was consistent, unaided, hands-on 
practice — building and breaking things myself, the way I'd be expected to on the job. 
That's the gap this repository was built to close.

Obiora also pushed me to change how I approached the job search itself — to stop applying 
to a handful of roles and wait, and instead apply broadly and consistently, week over 
week. He also encouraged me to post consistently on LinkedIn, not just publicly on my 
main feed but directly into relevant communities like SRE and DevOps groups, to reach the 
right audience. That shift is reflected below: 35+ applications submitted, a technical 
take-home project completed, and active interview conversations underway.

### Where I Started

Rebuilding hands-on AWS and Linux skills from the ground up, starting with AWS Console 
basics (IAM, VPC, EC2).

### What I Built

- A full three-tier AWS architecture build (Steps 1–15) in paired Bash and PowerShell — 
  IAM, VPC/networking, EC2 (Linux + Windows), S3, EBS/EFS, load balancing, autoscaling, 
  RDS, DynamoDB, Lambda, CloudFormation, CloudWatch, and Systems Manager
- A set of Linux system administration scripts covering routine checks, user 
  provisioning/offboarding, and troubleshooting
- Practical Git/GitHub workflow skills — branching, pull requests, code review, and merging

### What I Learned

- How to go from AWS Console click-ops to CLI-driven, repeatable infrastructure builds
- Collaborative Git workflows (not just pushing to main)
- How to turn hands-on practice into an applied, high-volume job search strategy

### Where I Am Now

Actively interviewing for DevOps/Cloud roles, with this repo serving as live proof of 
hands-on capability — and a stronger resume and LinkedIn presence behind it.

### What's Next

Expanding into Terraform/IaC, adding Kubernetes and CI/CD sections, and continuing to 
apply this repo's pattern — and the job search discipline Obiora helped instill — to 
the next stage of my career.

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

The [`aws/`](aws/) folder contains paired PowerShell and Bash scripts for creating and practicing with AWS services, covering a full three-tier architecture build from IAM setup through Systems Manager. See [`aws/README.md`](aws/README.md) for the full step map, resource discovery notes, and cost warnings.

| Step | PowerShell | Bash |
| --- | --- | --- |
| 1 | [aws-step1-create-user.ps1](aws/aws-step1-create-user.ps1) | [aws-step1-create-user.sh](aws/aws-step1-create-user.sh) |
| 2 | [aws-step2-setup-vpc.ps1](aws/aws-step2-setup-vpc.ps1) | [aws-step2-setup-vpc.sh](aws/aws-step2-setup-vpc.sh) |
| 3 | [aws-step3-launch-ubuntu-ec2.ps1](aws/aws-step3-launch-ubuntu-ec2.ps1) | [aws-step3-launch-ubuntu-ec2.sh](aws/aws-step3-launch-ubuntu-ec2.sh) |
| 3 | [aws-step3-launch-windows-ec2.ps1](aws/aws-step3-launch-windows-ec2.ps1) | [aws-step3-launch-windows-ec2.sh](aws/aws-step3-launch-windows-ec2.sh) |
| 4 | [aws-step4-secure-s3.ps1](aws/aws-step4-secure-s3.ps1) | [aws-step4-secure-s3.sh](aws/aws-step4-secure-s3.sh) |
| 5 | [aws-step5-setup-3-tier-architecture-windows-ec2.ps1](aws/aws-step5-setup-3-tier-architecture-windows-ec2.ps1) | [aws-step5-setup-3-tier-architecture-ubuntu-ec2.sh](aws/aws-step5-setup-3-tier-architecture-ubuntu-ec2.sh) |
| 6 | [aws-step6-attach-ebs.ps1](aws/aws-step6-attach-ebs.ps1) | [aws-step6-attach-ebs.sh](aws/aws-step6-attach-ebs.sh) |
| 7 | [aws-step7-create-efs.ps1](aws/aws-step7-create-efs.ps1) | [aws-step7-create-efs.sh](aws/aws-step7-create-efs.sh) |
| 8 | [aws-step8-create-elb.ps1](aws/aws-step8-create-elb.ps1) | [aws-step8-create-elb.sh](aws/aws-step8-create-elb.sh) |
| 9 | [aws-step9-create-autoscaling.ps1](aws/aws-step9-create-autoscaling.ps1) | [aws-step9-create-autoscaling.sh](aws/aws-step9-create-autoscaling.sh) |
| 10 | [aws-step10-create-rds.ps1](aws/aws-step10-create-rds.ps1) | [aws-step10-create-rds.sh](aws/aws-step10-create-rds.sh) |
| 11 | [aws-step11-create-dynamodb.ps1](aws/aws-step11-create-dynamodb.ps1) | [aws-step11-create-dynamodb.sh](aws/aws-step11-create-dynamodb.sh) |
| 12 | [aws-step12-create-lambda.ps1](aws/aws-step12-create-lambda.ps1) | [aws-step12-create-lambda.sh](aws/aws-step12-create-lambda.sh) |
| 13 | [aws-step13-deploy-cloudformation.ps1](aws/aws-step13-deploy-cloudformation.ps1) | [aws-step13-deploy-cloudformation.sh](aws/aws-step13-deploy-cloudformation.sh) |
| 14 | [aws-step14-create-cloudwatch.ps1](aws/aws-step14-create-cloudwatch.ps1) | [aws-step14-create-cloudwatch.sh](aws/aws-step14-create-cloudwatch.sh) |
| 15 | [aws-step15-systems-manager.ps1](aws/aws-step15-systems-manager.ps1) | [aws-step15-systems-manager.sh](aws/aws-step15-systems-manager.sh) |

Step 12 also includes [aws-step12-lambda-function.py](aws/aws-step12-lambda-function.py), and Step 13 includes [aws-step13-cloudformation-template.yaml](aws/aws-step13-cloudformation-template.yaml).

These scripts are intended to support interview prep by connecting theory to practical command-line work.

## Current Linux/Bash Scripts

The [`linux-bash-shell/`](linux-bash-shell/) folder contains standalone bash scripts automating common Linux system administration tasks — routine checks, user provisioning/offboarding, and troubleshooting. See [`linux-bash-shell/README.md`](linux-bash-shell/README.md) for full descriptions.

| Script | Category |
| --- | --- |
| [disk_usage_check.sh](linux-bash-shell/disk_usage_check.sh) | Routine |
| [log_archive.sh](linux-bash-shell/log_archive.sh) | Routine |
| [patch_audit.sh](linux-bash-shell/patch_audit.sh) | Routine |
| [user_access_review.sh](linux-bash-shell/user_access_review.sh) | Routine |
| [process_monitor.sh](linux-bash-shell/process_monitor.sh) | Routine |
| [cron_audit.sh](linux-bash-shell/cron_audit.sh) | Routine |
| [service_health_check.sh](linux-bash-shell/service_health_check.sh) | Routine |
| [create_user.sh](linux-bash-shell/create_user.sh) | Provisioning |
| [offboard_user.sh](linux-bash-shell/offboard_user.sh) | Provisioning |
| [service_recovery.sh](linux-bash-shell/service_recovery.sh) | Troubleshooting |
| [disk_full_response.sh](linux-bash-shell/disk_full_response.sh) | Troubleshooting |
| [network_diagnostics.sh](linux-bash-shell/network_diagnostics.sh) | Troubleshooting |

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

This is an active learning repository. The AWS section now covers a full three-tier architecture build (Steps 1–15), and the Linux/Bash section has an initial set of system administration scripts. Additional folders and examples will be added over time for Azure, GCP, Git/GitHub, Terraform, Ansible, Docker, Kubernetes, Observability, and Security/Compliance.