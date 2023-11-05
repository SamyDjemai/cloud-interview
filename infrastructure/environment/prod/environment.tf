module "environment" {
  source = "../../modules/environment"

  environment = "prod"

  network = {
    vpc_cidr_block = "172.31.0.0/16"
  }

  ssh = {
    key_pair_name = "framework"
  }

  bastion = {
    instance_type = "t3.micro"
  }

  eks = {
    cluster_name        = "samyd-ornikar-prod"
    node_instance_types = ["t3.micro"]
    min_size            = 3
    max_size            = 9
    desired_size        = 6
  }
}
