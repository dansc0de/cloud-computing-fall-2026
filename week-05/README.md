# Week 5: Compose, ECR, and Fargate

## Setup

On your laptop, from this folder:

```bash
multipass launch 24.04 -n in-class --cloud-init cloud-init.yaml
multipass exec in-class -- cloud-init status --wait
multipass shell in-class
```

This VM has Docker, the Compose plugin, the AWS CLI, Terraform, and uv. It needs a bit more room than week 4, so add `--memory 4G --disk 15G` to the launch command if the stack feels slow.

Inside the VM:

```bash
docker compose version && aws --version && terraform version
git clone https://github.com/dansc0de/cloud-computing-fall-2026.git
cd cloud-computing-fall-2026/week05/compose
```

Configure AWS credentials the same way you did in week 3:

```bash
aws configure
aws sts get-caller-identity
```

`permission denied` on the Docker socket? Run `exit`, then `multipass shell in-class` again.

## Demos

1. [Docker Compose](compose/) - a two-service stack locally, in one file
2. [Push to ECR](ecr/) - IAM login, tagging, and layer reuse
3. [Fargate](fargate/) - one task, two containers, deployed with Terraform

## Cleanup

```bash
cd fargate && terraform destroy
# @note we need to use force because images exist in the repository
aws ecr delete-repository --repository-name cs1660/proxy --force
aws ecr delete-repository --repository-name cs1660/mock-llm --force
```

```bash
# on your laptop
multipass delete in-class && multipass purge
```
