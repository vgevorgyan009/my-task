
terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "myapp-tf-s3-bucket69"
    key = "mytest2/state.tfstate"
    region = "eu-west-3"
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      CreatedBy = "Terraform"
    }
  }
}

module "my-network" {
  source            = "./modules/network"
  vpc_cidr_block = var.vpc_cidr_block
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  env_prefix = var.env_prefix
}

module "my-webapp" {
  source = "./modules/webapp"
  vpc_id = module.my-network.vpc.id
  public_subnets_ids = module.my-network.public_subnets
  private_subnets_ids = module.my-network.private_subnets
}
