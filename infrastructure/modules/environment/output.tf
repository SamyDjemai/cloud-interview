output "account_id" {
  description = "The ID of the current account"
  value       = data.aws_caller_identity.current.account_id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "key_pair_name" {
  description = "The name of the key pair"
  value       = data.aws_key_pair.main.key_name
}
