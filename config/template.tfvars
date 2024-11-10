# General
aws_region = "us-east-2"
workload   = "landscape"

# Landscape
landscape_certbot_email = "you@example.com"

# Ubuntu Landscape instance
landscape_server_fqdn           = "landscape@example.com"
ec2_landscape_create_elastic_ip = true
ec2_landscape_ami               = "ami-01ebf7c0e446f85f9" # Ubuntu 24.04 LTS ARM64
ec2_landscape_instance_type     = "t4g.medium"
ec2_landscape_volume_size       = 20

# Ubuntu test server
create_ubuntu_server            = false
ec2_ubuntu_server_ami           = "ami-01ebf7c0e446f85f9" # Ubuntu 24.04 LTS ARM64
ec2_ubuntu_server_instance_type = "t4g.micro"
