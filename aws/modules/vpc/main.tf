### Variables ###
locals {
  cidr_prefix = "10.0"
  az1         = "${var.aws_region}a"
  az2         = "${var.aws_region}b"
}

### VPC ###

resource "aws_vpc" "main" {
  cidr_block           = "${local.cidr_prefix}.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.workload}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ig-${var.workload}"
  }
}

### PRIVATE ###

# resource "aws_route_table" "private1" {
#   vpc_id = aws_vpc.main.id
#   tags = {
#     Name = "rt-${var.workload}-priv1"
#   }
# }

# resource "aws_route_table" "private2" {
#   vpc_id = aws_vpc.main.id
#   tags = {
#     Name = "rt-${var.workload}-priv2"
#   }
# }

# resource "aws_subnet" "private1" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "${local.cidr_prefix}.91.0/24"
#   availability_zone = local.az1

#   tags = {
#     Name = "subnet-${var.workload}-priv1"
#   }
# }

# resource "aws_subnet" "private2" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "${local.cidr_prefix}.92.0/24"
#   availability_zone = local.az2

#   tags = {
#     Name = "subnet-${var.workload}-priv2"
#   }
# }

# resource "aws_route_table_association" "private1" {
#   subnet_id      = aws_subnet.private1.id
#   route_table_id = aws_route_table.private1.id
# }

# resource "aws_route_table_association" "private2" {
#   subnet_id      = aws_subnet.private2.id
#   route_table_id = aws_route_table.private2.id
# }

### PUBLIC ###

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "rt-${var.workload}-public"
  }
}

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "${local.cidr_prefix}.1.0/24"
  availability_zone = local.az1

  # CKV_AWS_130
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-pub1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "${local.cidr_prefix}.2.0/24"
  availability_zone = local.az2

  # CKV_AWS_130
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.workload}-pub2"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}


### REMOVE DEFAULT ###

resource "aws_default_route_table" "internet" {
  default_route_table_id = aws_vpc.main.default_route_table_id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
}
