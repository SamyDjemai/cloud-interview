variable "environment" {
  type        = string
  description = "The environment to deploy to. Can be `prod`."
  default     = "test"

  validation {
    condition     = contains(["prod"], var.environment)
    error_message = "Environment must be one of [prod]"
  }
}

variable "network" {
  type = object({
    vpc_cidr_block = string
  })
}

variable "ssh" {
  type = object({
    key_pair_name = string
  })
}

variable "bastion" {
  type = object({
    instance_type = string
  })
}

variable "eks" {
  type = object({
    cluster_name        = string
    node_instance_types = list(string)
    min_size            = number
    max_size            = number
    desired_size        = number
  })
}
