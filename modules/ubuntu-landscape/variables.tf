variable "ami" {
  type = string
}

variable "instance_type" {
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

variable "ec2_use_spot_instance" {
  type = bool
}
