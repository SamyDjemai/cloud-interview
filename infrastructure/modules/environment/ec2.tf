resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}

data "aws_key_pair" "main" {
  key_name = var.ssh.key_pair_name
}
