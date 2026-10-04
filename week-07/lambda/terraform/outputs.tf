output "function_name" {
  value = aws_lambda_function.estimate.function_name
}

output "image_uri" {
  value = aws_lambda_function.estimate.image_uri
}

output "try_it" {
  value = <<-EOT
    ./invoke.sh "how many tokens is this message"     # cold start: REPORT line has Init Duration
    ./invoke.sh "how many tokens is this message"     # warm: same env_id, no Init Duration
    ./invoke.sh "slow one" 5                           # Task timed out after 3.00 seconds
    ./burst.sh 10                                      # 10 at once: several new env_ids
    WORK=300000 ./invoke.sh "cpu bound"                # note Duration, then ./deploy.sh -var memory_mb=1024 and rerun
    aws logs tail ${aws_cloudwatch_log_group.lambda.name} --follow
  EOT
}
