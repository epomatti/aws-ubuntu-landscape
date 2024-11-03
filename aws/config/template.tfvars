aws_region = "us-east-2"
workload   = "landscape"

ec2_landscape_ami           = "ami-0b8e245d9e93c05fa" # Ubuntu 24.04 LTS ARM64
ec2_landscape_instance_type = "t4g.medium"
ec2_landscape_volume_size   = 20

create_ubuntu_server            = false
ec2_ubuntu_server_ami           = "ami-0b8e245d9e93c05fa" # Ubuntu 24.04 LTS ARM64
ec2_ubuntu_server_instance_type = "t4g.micro"
