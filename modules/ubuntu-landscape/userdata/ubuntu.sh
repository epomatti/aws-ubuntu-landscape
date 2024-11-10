#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt update
apt upgrade -y

### Required for Ubuntu Landscape
apt install -y ca-certificates software-properties-common zip unzip
add-apt-repository -y ppa:landscape/self-hosted-24.04 # https://ubuntu.com/landscape/docs/self-hosted-landscape
snap install certbot --classic

curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
