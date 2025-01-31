### General
aws_region = "us-east-2"
workload   = "landscape"

### Landscape
landscape_certbot_email = "you@example.com"

### Ubuntu Landscape instance
create_ubuntu_landscape         = false
landscape_server_fqdn           = "landscape@example.com"
ec2_landscape_create_elastic_ip = true
ec2_landscape_ami               = "ami-01ebf7c0e446f85f9" # Ubuntu 24.04 LTS ARM64
ec2_landscape_instance_type     = "t4g.medium"
ec2_landscape_volume_size       = 20

### Ubuntu test server
create_ubuntu_server            = false
ec2_ubuntu_server_ami           = "ami-01ebf7c0e446f85f9" # Ubuntu 24.04 LTS ARM64
ec2_ubuntu_server_instance_type = "t4g.micro"

### Ubuntu Pro Server
create_ubuntu_pro_server = true

# ami-0a7e9bed072bb379b : Canonical, Ubuntu Server Pro, 22.04 LTS, amd64 jammy image build on 2024-06-06
# ami-01819ddcdab78e06d : Ubuntu Pro - Ubuntu Server Pro 24.04 LTS (HVM), EBS General Purpose (SSD) Volume Type. Support available from Canonical
# ami-06f50fcd71f272ce1 : Canonical, Ubuntu Server Pro, 22.04 LTS, arm64 jammy image build on 2024-06-06
ec2_ubuntu_pro_server_ami            = "ami-0a7e9bed072bb379b"
ec2_ubuntu_pro_server_instance_type  = "t3.micro"
ec2_ubuntu_pro_server_os_volume_size = 8
