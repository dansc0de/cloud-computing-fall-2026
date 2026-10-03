terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # @note: remote state config
  backend "s3" {
    bucket = "itcc-tfstate-dpm79"
    key    = "week-07/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      course = "cs1660"
      week   = "07"
    }
  }
}

locals {
  name = "cs1660-w7-estimate"
}

# The registry the function's image lives in (week 5). deploy.sh creates this first,
# because a container-image function cannot be created until its image exists.
resource "aws_ecr_repository" "lambda" {
  name                 = local.name
  image_tag_mutability = "MUTABLE"
  force_delete         = true # let terraform destroy remove it even with images inside
}

# Resource policy on the REPOSITORY: lets the Lambda service pull images from it.
resource "aws_ecr_repository_policy" "lambda_pull" {
  repository = aws_ecr_repository.lambda.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "LambdaECRImageRetrievalPolicy"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer"]
    }]
  })
}

# Execution role: what the function's CODE may do. Lambda assumes it on every invocation.
resource "aws_iam_role" "lambda" {
  name = local.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Only permission it needs: write its own logs.
resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create the log group ourselves so it gets a retention period instead of "never expire".
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.name}"
  retention_in_days = 3
}

resource "aws_lambda_function" "estimate" {
  function_name = local.name
  role          = aws_iam_role.lambda.arn
  package_type  = "Image"
  # No runtime or handler here: the image's base layer is the runtime, its CMD is the handler.
  image_uri     = "${aws_ecr_repository.lambda.repository_url}:${var.image_tag}"
  architectures = [var.architecture] # must match the platform the image was built for
  memory_size   = var.memory_mb
  timeout       = var.timeout_s

  depends_on = [
    aws_iam_role_policy_attachment.logs,
    aws_cloudwatch_log_group.lambda,
    aws_ecr_repository_policy.lambda_pull,
  ]
}
