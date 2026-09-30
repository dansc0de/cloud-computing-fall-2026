terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      course = "cs1660"
      week   = "06"
    }
  }
}

# api — name and protocol; no routes or backend yet
resource "aws_apigatewayv2_api" "front_door" {
  name          = "cs1660-w6-front-door"
  protocol_type = "HTTP"
  description   = "Week 6 demo: a managed front door for the LLM proxy"
}

# integration — backend is the proxy (8080), not the model (localhost:8000);
# {path} comes from the route's greedy variable, so /v1/chat -> /chat
resource "aws_apigatewayv2_integration" "llm_proxy" {
  api_id                 = aws_apigatewayv2_api.front_door.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = "${var.backend_url}/{path}"
  payload_format_version = "1.0"
  timeout_milliseconds   = 5000 # short so a dead backend shows up fast as a 504
}

# routes — only GET and POST are routed; DELETE /v1/chat never reaches the backend
resource "aws_apigatewayv2_route" "get_v1" {
  api_id    = aws_apigatewayv2_api.front_door.id
  route_key = "GET /v1/{path+}"
  target    = "integrations/${aws_apigatewayv2_integration.llm_proxy.id}"
}

resource "aws_apigatewayv2_route" "post_v1" {
  api_id    = aws_apigatewayv2_api.front_door.id
  route_key = "POST /v1/{path+}"
  target    = "integrations/${aws_apigatewayv2_integration.llm_proxy.id}"
}

resource "aws_cloudwatch_log_group" "access" {
  name              = "/apigw/cs1660-w6-front-door"
  retention_in_days = 3
}

# stage — $default means no /prod prefix in the url
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.front_door.id
  name        = "$default"
  auto_deploy = true

  # tiny limits so the class can trip throttling with a loop of curls
  default_route_settings {
    throttling_burst_limit = var.burst_limit
    throttling_rate_limit  = var.rate_limit
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.access.arn
    format = jsonencode({
      requestId         = "$context.requestId"
      ip                = "$context.identity.sourceIp"
      method            = "$context.httpMethod"
      path              = "$context.path"
      routeKey          = "$context.routeKey"
      status            = "$context.status"
      latencyMs         = "$context.responseLatency"
      integrationStatus = "$context.integrationStatus"
      integrationError  = "$context.integrationErrorMessage"
    })
  }
}
