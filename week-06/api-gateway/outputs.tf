output "api_url" {
  description = "Public HTTPS endpoint of the front door"
  value       = aws_apigatewayv2_api.front_door.api_endpoint
}

output "try_it" {
  value = <<-EOT
    # health check
    curl -s ${aws_apigatewayv2_api.front_door.api_endpoint}/v1/health | jq .

    # send a chat request
    curl -s -X POST ${aws_apigatewayv2_api.front_door.api_endpoint}/v1/chat \
      -H 'Content-Type: application/json' \
      -d '{"user":"alice","message":"what is cloud computing?"}' | jq .

    # check token usage for a user
    curl -s ${aws_apigatewayv2_api.front_door.api_endpoint}/v1/usage/alice | jq .

    # should 403 — DELETE is not routed
    curl -s -o /dev/null -w '%%{http_code}\n' -X DELETE ${aws_apigatewayv2_api.front_door.api_endpoint}/v1/chat

    # tail access logs
    aws logs tail ${aws_cloudwatch_log_group.access.name} --follow
  EOT
}
