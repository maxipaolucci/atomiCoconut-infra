#!/bin/bash

echo "Setting up Unified CloudWatch Agent..."

FILE="cloudWatchAgentConfig-updated.json"     
if [ -f $FILE ]; then
  echo "$FILE removed."
  rm $FILE
else
  echo "File $FILE does not exist."
fi

cp cloudWatchAgentConfig.json cloudWatchAgentConfig-updated.json

SERVER_CONTAINER_ID=$(docker ps | grep atomic-coconut-server | awk '{print $1}')
if [[ -z "$SERVER_CONTAINER_ID" ]]; then 
  echo "ERROR: aCo server container not found."
  exit 1; 
fi
echo "aCo server container id: $SERVER_CONTAINER_ID"

ENVIRONMENT_TYPE=$(sudo /opt/elasticbeanstalk/bin/get-config environment | jq .ENVIRONMENT_TYPE | tr -d '"')
if [[ -z "$ENVIRONMENT_TYPE" ]]; then ENVIRONMENT_TYPE=production; fi
echo "Environment type: $ENVIRONMENT_TYPE"

sed -i "s?server-CONTAINER_ID-stdouterr?server-$SERVER_CONTAINER_ID-stdouterr?" cloudWatchAgentConfig-updated.json
sed -i "s?aco-ENVIRONMENT_TYPE?aco-$ENVIRONMENT_TYPE?" cloudWatchAgentConfig-updated.json
echo

echo "Setup cloudWatch agent..."
if [ -f /usr/share/collectd/types.db ]; then
  echo "Created file: /usr/share/collectd/types.db required by CloudWatch Agent."
  sudo mkdir -p /usr/share/collectd
  sudo touch /usr/share/collectd/types.db
fi
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:cloudWatchAgentConfig-updated.json -s

echo "CloudWatch Agent setup done."