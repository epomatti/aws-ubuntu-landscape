#!/usr/bin/env bash

instanceId=$(aws ssm get-parameter --name "landscape-server-instance-id" --query "Parameter.Value" --output text)
aws ec2 stop-instances --instance-ids "$instanceId"
