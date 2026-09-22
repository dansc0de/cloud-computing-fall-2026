#!/usr/bin/env bash
# Print the public IP of every running task in the cluster.
set -euo pipefail

CLUSTER="${1:-cs1660-week5}"

TASKS=$(aws ecs list-tasks --cluster "$CLUSTER" --desired-status RUNNING \
  --query 'taskArns' --output text)

if [ -z "$TASKS" ]; then
  echo "no running tasks in cluster $CLUSTER"
  exit 0
fi

for TASK in $TASKS; do
  ENI=$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$TASK" \
    --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" \
    --output text)
  IP=$(aws ec2 describe-network-interfaces --network-interface-ids "$ENI" \
    --query 'NetworkInterfaces[0].Association.PublicIp' --output text)
  echo "$IP  ($(basename "$TASK"))"
done
