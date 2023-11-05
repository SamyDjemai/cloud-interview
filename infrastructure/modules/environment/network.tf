locals {
  public_subnets  = [aws_subnet.pub_1, aws_subnet.pub_2, aws_subnet.pub_3]
  private_subnets = [aws_subnet.app_1, aws_subnet.app_2, aws_subnet.app_3, aws_subnet.data_1, aws_subnet.data_2, aws_subnet.data_3, aws_subnet.bastion_1]
}

resource "aws_vpc" "main" {
  cidr_block = var.network.vpc_cidr_block
}

resource "aws_subnet" "pub_1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-west-3a"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 0)

  tags = {
    Name = "pub-1"
    # These tags are used for load balancer auto-discovery
    "kubernetes.io/cluster/${var.eks.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = "1"
  }
}

resource "aws_subnet" "pub_2" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-west-3b"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 1)

  tags = {
    Name                                            = "pub-2"
    "kubernetes.io/cluster/${var.eks.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = "1"
  }
}

resource "aws_subnet" "pub_3" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-west-3c"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 2)

  tags = {
    Name                                            = "pub-3"
    "kubernetes.io/cluster/${var.eks.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = "1"
  }
}

resource "aws_subnet" "app_1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-west-3a"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 3)

  tags = {
    Name                                            = "app-1"
    "kubernetes.io/cluster/${var.eks.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}

resource "aws_subnet" "app_2" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-west-3b"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 4)

  tags = {
    Name                                            = "app-2"
    "kubernetes.io/cluster/${var.eks.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}

resource "aws_subnet" "app_3" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-west-3c"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 5)

  tags = {
    Name                                            = "app-3"
    "kubernetes.io/cluster/${var.eks.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}

resource "aws_subnet" "data_1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-west-3a"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 6)

  tags = {
    Name = "data-1"
  }
}

resource "aws_subnet" "data_2" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-west-3b"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 7)

  tags = {
    Name = "data-2"
  }
}

resource "aws_subnet" "data_3" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-west-3c"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 8)

  tags = {
    Name = "data-3"
  }
}



resource "aws_subnet" "bastion_1" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-west-3a"
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, 9)
  tags = {
    Name = "bastion-1"
  }
}



resource "aws_default_network_acl" "main" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  egress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    rule_no    = 100
  }

  ingress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    rule_no    = 100
  }

  lifecycle {
    # Since this is a default resource, we don't want to trigger a change
    # whenever a subnet route table association is added or removed
    ignore_changes = [subnet_ids]
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "nat_gateway" {
  domain = "vpc"

  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.pub_1.id

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table_association" "public" {
  for_each = {
    for subnet in local.public_subnets :
    subnet.tags.Name => subnet
  }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = {
    for subnet in local.private_subnets :
    subnet.tags.Name => subnet
  }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_default_vpc_dhcp_options" "main" {}
