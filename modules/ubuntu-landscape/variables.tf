variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "workload" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "volume_size" {
  type = number
}

variable "ec2_landscape_create_elastic_ip" {
  type = bool
}
