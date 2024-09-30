#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt update
apt upgrade -y

apt install -y ca-certificates software-properties-common

# Utility only. Used later to install certbot if using the Quick Start deployment
snap install certbot --classic


reboot
