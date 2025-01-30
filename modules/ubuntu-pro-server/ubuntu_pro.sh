#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt update && apt upgrade -y

ua enable usg
apt install usg landscape-client -y

reboot
