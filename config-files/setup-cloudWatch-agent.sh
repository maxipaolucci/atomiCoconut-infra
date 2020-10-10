#!/bin/bash

echo "Setting up Unified CloudWatch Agent..."

SERVER_CONTAINER_ID=$(docker ps | grep atomic-coconut-server | awk '{print $1}')
echo "aCo server container id: $SERVER_CONTAINER_ID"

ENVIRONMENT_TYPE=$(sudo /opt/elasticbeanstalk/bin/get-config environment | jq .ENVIRONMENT_TYPE | tr -d '"')
if [[ -z "$ENVIRONMENT_TYPE" ]]; then ENVIRONMENT_TYPE=production; fi
echo "Environment type: $ENVIRONMENT_TYPE"

sed -i "s?server-CONTAINER_ID-stdouterr?server-$SERVER_CONTAINER_ID-stdouterr?" cloudWatchAgentConfig.json
sed -i "s?aco-ENVIRONMENT_TYPE?aco-$ENVIRONMENT_TYPE?" cloudWatchAgentConfig.json
echo

echo "Setup cloudWatch agent..."
sudo mkdir -p /usr/share/collectd
sudo touch /usr/share/collectd/types.db
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:cloudWatchAgentConfig.json -s

echo "CloudWatch Agent setup done."