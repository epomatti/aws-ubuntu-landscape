terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.75.1"
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
  source                          = "./modules/ubuntu-landscape"
  workload                        = var.workload
  ami                             = var.ec2_landscape_ami
  instance_type                   = var.ec2_landscape_instance_type
  vpc_id                          = module.vpc.vpc_id
  subnet_id                       = module.vpc.default_public_subnet_id
  volume_size                     = var.ec2_landscape_volume_size
  ec2_landscape_create_elastic_ip = var.ec2_landscape_create_elastic_ip
}

module "ubuntu_server" {
  count         = var.create_ubuntu_server ? 1 : 0
  source        = "./modules/ubuntu-server"
  ami           = var.ec2_ubuntu_server_ami
  instance_type = var.ec2_ubuntu_server_instance_type
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.default_public_subnet_id
}

module "ssm" {
  source                       = "./modules/ssm"
  landscape_server_fqdn        = var.landscape_server_fqdn
  landscape_server_instance_id = module.ubuntu_landscape.instance_id
  landscape_certbot_email      = var.landscape_certbot_email
}
