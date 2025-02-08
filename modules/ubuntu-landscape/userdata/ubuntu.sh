#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt update
apt upgrade -y


### General Variables ###
unameMachine=$(uname -m)


### CloudWatch Agent ###
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 3600")
region=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)

cwAgentArch=""
if [[ "$unameMachine" == "aarch64" ]] ; then
  cwAgentArch="arm64"
elif [[ "$unameMachine" == "x86_64" ]] ; then
  cwAgentArch="amd64"
else
  echo "Failed to convert uname machine [$unameMachine]. No match was found" >&2
fi

wget "https://amazoncloudwatch-agent-$region.s3.$region.amazonaws.com/ubuntu/$cwAgentArch/latest/amazon-cloudwatch-agent.deb"
dpkg -i -E ./amazon-cloudwatch-agent.deb

ssmParameterName=AmazonCloudWatch-linux-terraform
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:$ssmParameterName

rm amazon-cloudwatch-agent.deb


### Required for Ubuntu Landscape
ubuntuVersion=24.04
apt install -y ca-certificates software-properties-common zip unzip
add-apt-repository -y "ppa:landscape/self-hosted-$ubuntuVersion" # https://ubuntu.com/landscape/docs/self-hosted-landscape
snap install certbot --classic

curl "https://awscli.amazonaws.com/awscli-exe-linux-$unameMachine.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install


reboot
