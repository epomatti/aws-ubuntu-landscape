#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt update
apt upgrade -y

apt install -y ca-certificates software-properties-common

# hostnamectl set-hostname "$FQDN"

# https://ubuntu.com/landscape/docs/self-hosted-landscape
# add-apt-repository -y ppa:landscape/self-hosted-24.04
# apt update && apt-get install -y landscape-server-quickstart


# snap install certbot --classic






# EMAIL="YOUR-EMAIL@ADDRESS.COM"
# sudo certbot --apache --non-interactive --no-redirect --agree-tos --email $EMAIL --domains $(hostname --long)