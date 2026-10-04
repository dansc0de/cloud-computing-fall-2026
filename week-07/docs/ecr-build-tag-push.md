# ECR: Build, Tag, and Push

## 1. Create the ECR repository

**CLI:**

```bash
aws ecr create-repository \
  --repository-name lambda-cost-usage \
  --image-scanning-configuration scanOnPush=true \
  --region us-east-1
```

**Terraform:**

```hcl
resource "aws_ecr_repository" "lambda" {
  name                 = "lambda-cost-usage"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
```

## 2. Authenticate Docker to ECR

Token lasts 12 hours.

```bash
REGION=us-east-1
NAME=lambda-cost-usage
REPO="$(aws ecr describe-repositories --region "$REGION" \
  --repository-names "$NAME" --query 'repositories[0].repositoryUri' --output text)"

aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "${REPO%%/*}"
```

## 3. Build and push

```bash
TAG="$(git rev-parse --short HEAD)"
docker build -t "$REPO:$TAG" .
docker push "$REPO:$TAG"
```

This builds for your host architecture. Set the terraform `architecture` variable to match (`x86_64` on Intel/AMD, `arm64` on Apple Silicon — defaults to `x86_64`).
