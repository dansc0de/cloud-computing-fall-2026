variable "region" {
  type    = string
  default = "us-east-1"
}

variable "backend_url" {
  description = "Base URL of the backend, no trailing slash. e.g. http://<task-public-ip>:8080 or https://httpbin.org/anything"
  type        = string

  validation {
    condition     = can(regex("^https?://[^/].*[^/]$", var.backend_url))
    error_message = "backend_url must start with http:// or https:// and must not end with a slash."
  }
}

variable "burst_limit" {
  description = "Token bucket size: requests allowed in a burst before throttling"
  type        = number
  default     = 2
}

variable "rate_limit" {
  description = "Steady-state requests per second"
  type        = number
  default     = 1
}
