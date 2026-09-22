variable "region" {
  description = "AWS region for every resource"
  type        = string
  default     = "us-east-2"
}

variable "name" {
  description = "Name prefix, so two students in one account do not collide"
  type        = string
  default     = "cs1660-week5"
}

variable "proxy_image" {
  description = "ECR URI of the proxy image, for example 1234.dkr.ecr.us-east-2.amazonaws.com/cs1660/proxy:v1"
  type        = string
}

variable "llm_image" {
  description = "ECR URI of the mock LLM image"
  type        = string
}

variable "desired_count" {
  description = "How many copies of the task the service keeps running"
  type        = number
  default     = 1
}

variable "allowed_cidr" {
  description = "Who may reach port 8080. Narrow this to your own IP when you can."
  type        = string
  default     = "0.0.0.0/0"
}
