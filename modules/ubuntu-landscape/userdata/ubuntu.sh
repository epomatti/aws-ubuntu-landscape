#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt update
apt upgrade -y

### Required for Ubuntu Landscape
apt install -y ca-certificates software-properties-common
add-apt-repository -y ppa:landscape/self-hosted-24.04 # https://ubuntu.com/landscape/docs/self-hosted-landscape
snap install certbot --classic
