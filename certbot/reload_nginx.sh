#!/bin/bash

#this is used to restart the container
nginxImageTag="latest"
if [[ ! -z "$1" ]]; then
	nginxImageTag=$1
fi

echo "### Reloading nginx (tagged: $nginxImageTag) ..."
nginx_container_name=$(docker ps | grep atomic-coconut-nginx:$nginxImageTag | awk '{print $NF}')
echo "NGINX container name: $nginx_container_name"

docker exec $nginx_container_name nginx -s reload
