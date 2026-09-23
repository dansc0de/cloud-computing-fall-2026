# Demo 3: One task, two containers, on Fargate

The same two containers from demo 1, now running as a single ECS task. They share a network namespace, so the proxy reaches the model at `http://localhost:8000`.

Requires demo 2 (both images pushed) and AWS credentials in your VM.

## Deploy

```bash
cd fargate
cp terraform.tfvars.example terraform.tfvars   # then edit in your account number
terraform init
terraform plan
terraform apply
```

While the plan scrolls by, point out the execution role, the task role, and the `awslogs` block.

## Watch it start

```bash
aws ecs describe-services --cluster cs1660-week5 --services cs1660-week5 \
  --query 'services[0].{desired:desiredCount,running:runningCount,status:status}'

aws ecs list-tasks --cluster cs1660-week5
```

Tasks move through PROVISIONING (an ENI is being attached), PENDING (images pulling), then RUNNING.

## Use it

```bash
./task-ip.sh
IP=$(./task-ip.sh | head -1 | awk '{print $1}')

curl -s http://$IP:8080/health
curl -s -X POST http://$IP:8080/chat -H 'content-type: application/json' \
  -d '{"user": "team-01", "message": "hello from Fargate"}'
curl -s http://$IP:8080/usage/team-01
```

The reply comes from the sidecar over localhost, and `served_by` is the task ID, which makes the scale-out below easy to see.

## Logs

```bash
aws logs tail /ecs/cs1660-week5 --follow
aws logs tail /ecs/cs1660-week5 --since 10m --filter-pattern chat
```

## Scale

```bash
terraform apply -var desired_count=2
./task-ip.sh                    # two IPs
```

Each task has its own ENI, its own IP, and its own copy of both containers.

## Clean up

```bash
terraform destroy
```

## When something breaks

```bash
# why did the task stop?
aws ecs describe-tasks --cluster cs1660-week5 --tasks $TASK \
  --query 'tasks[0].{status:lastStatus,reason:stoppedReason,containers:containers[].{name:name,reason:reason}}'
```

| Symptom | Usual cause |
|---|---|
| `CannotPullContainerError` | Execution role cannot read ECR, or the task has no route out (public IP, NAT, or VPC endpoints) |
| `exec format error` in the logs | Image built on arm64. Rebuild with `--platform linux/amd64` |
| Proxy logs show `AccessDenied` from an AWS call | Task role, not execution role |
| Task flips RUNNING then STOPPED | The llm health check never passed, so the proxy dependency failed |
