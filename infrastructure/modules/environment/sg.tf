locals {
  cluster_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "bastion"
  vpc_id      = aws_vpc.main.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "bastion"
  }

  revoke_rules_on_delete = null
}

# The security group is automatically created by the EKS cluster
# so we don't manage it with Terraform, but we need to reference it
resource "aws_security_group_rule" "allow_https_from_bastion_to_eks" {
  security_group_id        = local.cluster_security_group_id
  source_security_group_id = aws_security_group.bastion.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 443
  to_port   = 443
}
