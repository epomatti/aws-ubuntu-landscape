#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt update && apt upgrade -y

pro enable usg
apt install -y usg landscape-client

reboot
