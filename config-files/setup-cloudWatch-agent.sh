#!/bin/bash

echo "Setting up Unified CloudWatch Agent..."
SERVER_CONTAINER_ID=$(docker ps | grep atomic-coconut-server | awk '{print $1}')
echo "aCo server container id: $SERVER_CONTAINER_ID"
sed -i "s?server-CONTAINER_ID-stdouterr?server-$SERVER_CONTAINER_ID-stdouterr?" cloudWatchAgentConfig.json
echo
echo "Setup cloudWatch agent..."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:cloudWatchAgentConfig.json -s

echo "CloudWatch Agent setup done."