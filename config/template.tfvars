### General
aws_region = "us-east-2"
workload   = "landscape"

### Landscape
landscape_certbot_email = "you@example.com"

### Ubuntu Landscape instance
create_ubuntu_landscape     = false
landscape_server_fqdn       = "landscape@example.com"
ec2_landscape_ami           = "ami-0b14a7269696d2dcb" # Canonical, Ubuntu Server Pro, 24.04 LTS, arm64 noble image
ec2_landscape_instance_type = "t4g.medium"
ec2_landscape_volume_size   = 50
ec2_use_spot_instance       = false

### Ubuntu test server
create_ubuntu_server            = false
ec2_ubuntu_server_ami           = "ami-0ac5d9e789dbb455a" # Canonical, Ubuntu, 24.04, arm64 noble image
ec2_ubuntu_server_instance_type = "t4g.micro"

### Ubuntu Pro Server*
# *Livepatch not supported for Arm64, *USG currently unsupported on 24.04
create_ubuntu_pro_server             = false
ec2_ubuntu_pro_server_ami            = "ami-0bd9f07e01735115d" # Ubuntu Server Pro 22.04 Amd64
ec2_ubuntu_pro_server_instance_type  = "t3.small"
ec2_ubuntu_pro_server_os_volume_size = 10
