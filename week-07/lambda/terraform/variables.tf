variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository (created before terraform apply)"
  type        = string
  default     = "lambda-cost-usage"
}

variable "image_tag" {
  description = "Tag of the image in ECR. deploy.sh sets it to a hash of the Dockerfile and source."
  type        = string
}

variable "architecture" {
  description = "x86_64 or arm64. deploy.sh matches it to the machine that built the image."
  type        = string
  default     = "x86_64"

  validation {
    condition     = contains(["x86_64", "arm64"], var.architecture)
    error_message = "architecture must be x86_64 or arm64."
  }
}

variable "memory_mb" {
  description = "Memory in MB. CPU scales with it, so this is also the CPU knob."
  type        = number
  default     = 128
}

variable "timeout_s" {
  description = "Function timeout. 3 seconds is the Lambda default, kept here on purpose."
  type        = number
  default     = 3
}
