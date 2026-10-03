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

## 3. Build the image

```bash
docker build --platform linux/amd64 --provenance=false -t "$NAME" .
```

Use `linux/arm64` on Apple Silicon / ARM machines.

`--provenance=false` prevents buildx from pushing an image index with an attestation manifest that Lambda rejects.

## 4. Tag the image

```bash
TAG="$(cat Dockerfile src/handler.py | sha256sum | cut -c1-12)"
docker tag "$NAME" "$REPO:$TAG"
```

The content-hash tag means the same code always produces the same tag — a code change produces a new one.

## 5. Push to ECR

```bash
docker push "$REPO:$TAG"
```
