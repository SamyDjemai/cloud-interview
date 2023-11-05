data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "bastion_1" {
  availability_zone = "eu-west-3a"

  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.bastion.instance_type

  iam_instance_profile = aws_iam_instance_profile.ssm.name

  key_name = data.aws_key_pair.main.key_name

  subnet_id              = aws_subnet.bastion_1.id
  vpc_security_group_ids = [aws_security_group.bastion.id]

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

  monitoring = true

  credit_specification {
    cpu_credits = "standard"
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name  = "bastion-1"
    "env" = "${var.environment}"
  }
}
