# Demo 2: Push to ECR

Two images go to AWS: the proxy and the mock LLM. They become the two containers of one Fargate task in demo 3.

## Set up your shell

```bash
export AWS_REGION=us-east-1
export ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
export REGISTRY=$ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com
echo $REGISTRY
```

## Create the repositories

```bash
aws ecr create-repository --repository-name cs1660/proxy   --image-scanning-configuration scanOnPush=true
aws ecr create-repository --repository-name cs1660/mock-llm --image-scanning-configuration scanOnPush=true
aws ecr describe-repositories --query 'repositories[].repositoryUri' --output table
```

## Log in

There is no registry password. IAM issues a token that is good for 12 hours.

```bash
aws ecr get-login-password --region $AWS_REGION \
  | docker login --username AWS --password-stdin $REGISTRY
```

## Build, tag, push

Build for the platform you deploy to. Fargate tasks here are amd64.

```bash
cd ../compose

docker build --platform linux/amd64 -t $REGISTRY/cs1660/proxy:v1 ./proxy
docker build --platform linux/amd64 -t $REGISTRY/cs1660/mock-llm:v1 ./mock-llm

docker push $REGISTRY/cs1660/proxy:v1
docker push $REGISTRY/cs1660/mock-llm:v1
```

## Watch layer reuse

Change one line of `proxy/main.py`, then push a second tag:

```bash
docker build --platform linux/amd64 -t $REGISTRY/cs1660/proxy:v2 ./proxy
docker push $REGISTRY/cs1660/proxy:v2      # only the changed layers upload
```

Tag with the git SHA, which is the only tag that answers "what is running right now?":

```bash
SHA=$(git rev-parse --short HEAD)
docker tag $REGISTRY/cs1660/proxy:v2 $REGISTRY/cs1660/proxy:$SHA
docker push $REGISTRY/cs1660/proxy:$SHA

aws ecr list-images --repository-name cs1660/proxy --output table
aws ecr describe-images --repository-name cs1660/proxy \
  --query 'sort_by(imageDetails,&imagePushedAt)[-1].[imageTags,imageSizeInBytes]'
```

## Housekeeping

```bash
# expire untagged images so old builds do not pile up
aws ecr put-lifecycle-policy --repository-name cs1660/proxy --lifecycle-policy-text \
  '{"rules":[{"rulePriority":1,"description":"expire untagged after 7 days","selection":{"tagStatus":"untagged","countType":"sinceImagePushed","countUnit":"days","countNumber":7},"action":{"type":"expire"}}]}'
```

Keep the repositories for demo 3. To remove them at the end of the lab:

```bash
aws ecr delete-repository --repository-name cs1660/proxy --force
aws ecr delete-repository --repository-name cs1660/mock-llm --force
```
