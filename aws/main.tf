terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.69.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
  workload   = var.workload
}

module "ubuntu_landscape" {
  source        = "./modules/ubuntu-landscape"
  workload      = var.workload
  ami           = var.ec2_landscape_ami
  instance_type = var.ec2_landscape_instance_type
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.default_public_subnet_id
}
