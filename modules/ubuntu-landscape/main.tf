locals {
  name = "landscape-host"
}

resource "aws_iam_instance_profile" "default" {
  name = "${local.name}-profile"
  role = aws_iam_role.default.id
}

resource "aws_eip" "default" {
  instance = aws_instance.default.id
  domain   = "vpc"
}

data "aws_subnet" "selected" {
  id = var.subnet_id
}

resource "aws_instance" "default" {
  ami           = var.ami
  instance_type = var.instance_type

  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.default.id]

  availability_zone    = data.aws_subnet.selected.availability_zone
  iam_instance_profile = aws_iam_instance_profile.default.id
  user_data            = file("${path.module}/userdata/ubuntu.sh")

  dynamic "instance_market_options" {
    for_each = var.ec2_use_spot_instance ? [1] : []
    content {
      market_type = "spot"
    }
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring    = false
  ebs_optimized = true

  root_block_device {
    encrypted   = true
    volume_size = var.volume_size

    tags = {
      Name = "vol-landscape-host"
    }
  }

  lifecycle {
    ignore_changes = [
      ami,
      associate_public_ip_address,
      user_data
    ]
  }

  tags = {
    Name = local.name
  }
}

### IAM Role ###

resource "aws_iam_role" "default" {
  name = local.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm-managed-instance-core" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "AmazonSSMReadOnlyAccess" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerPolicy" {
  role       = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_security_group" "default" {
  name        = "ec2-ssm-${local.name}"
  description = "Controls access for EC2 via Session Manager"
  vpc_id      = var.vpc_id

  tags = {
    Name = "sg-ssm-${local.name}"
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group_rule" "allow_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "allow_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "allow_ingress_grpc" {
  type              = "ingress"
  from_port         = 6554
  to_port           = 6554
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "allow_egress_internet_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "allow_egress_internet_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}
