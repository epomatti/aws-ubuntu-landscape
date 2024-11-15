variable "aws_region" {
  type = string
}

variable "workload" {
  type = string
}

variable "landscape_server_fqdn" {
  type = string
}

variable "landscape_certbot_email" {
  type = string
}

variable "ec2_landscape_create_elastic_ip" {
  type = string
}

variable "ec2_landscape_ami" {
  type = string
}

variable "ec2_landscape_instance_type" {
  type = string
}

variable "ec2_landscape_volume_size" {
  type = number
}

variable "create_ubuntu_server" {
  type = bool
}

variable "ec2_ubuntu_server_ami" {
  type = string
}

variable "ec2_ubuntu_server_instance_type" {
  type = string
}
