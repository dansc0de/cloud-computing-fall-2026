output "cluster" {
  value = aws_ecs_cluster.this.name
}

output "service" {
  value = aws_ecs_service.app.name
}

output "log_group" {
  value = aws_cloudwatch_log_group.app.name
}

output "task_ip_command" {
  description = "Run this to find the public IP of a running task"
  value       = "aws ecs list-tasks --cluster ${aws_ecs_cluster.this.name} --query 'taskArns[0]' --output text | xargs -I{} aws ecs describe-tasks --cluster ${aws_ecs_cluster.this.name} --tasks {} --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text | xargs -I{} aws ec2 describe-network-interfaces --network-interface-ids {} --query 'NetworkInterfaces[0].Association.PublicIp' --output text"
}
