variable "environment" {
  type        = string
  description = "The environment. Can be `prod`."

  validation {
    condition     = contains(["prod"], var.environment)
    error_message = "Environment must be one of [prod]"
  }
}


