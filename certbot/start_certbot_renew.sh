#!/bin/bash

echo "Starting certbot container to check to renew http certificates every 12hs..."
# this script is to rename the docker-compose-renew.yml file to docker-compose.yml and start certbot to check for certificates renewal
mv docker-compose.yml docker-compose.yml.bkp
mv docker-compose-renew.yml docker-compose.yml

docker-compose up -d

# rollback the rename to be able to run it again in case the certbot container stops
mv docker-compose.yml docker-compose-renew.yml
mv docker-compose.yml.bkp docker-compose.yml

echo "Cerbot container running."
echo