terraform {
  # For the moment, we don't use a remote backend since we often destroy and recreate the environment
  #
  # backend "s3" {
  #   encrypt        = true
  #   bucket         = "samyd-ornikar-terraform-state-prod"
  #   dynamodb_table = "samyd-ornikar-terraform-state-lock-prod"
  #   region         = "eu-west-3"
  #   key            = "terraform.tfstate"
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.24.0"
    }
  }

  required_version = "1.6.3"
}

provider "aws" {
  region = "eu-west-3"
}
