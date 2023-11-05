output "account_id" {
  description = "The ID of the current account"
  value       = module.environment.account_id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.environment.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.environment.vpc_cidr_block
}

output "key_pair_name" {
  description = "The name of the key pair"
  value       = module.environment.key_pair_name
}
