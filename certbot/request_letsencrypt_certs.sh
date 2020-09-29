#!/bin/bash

staging=1 # Set to 1 if you're testing your setup to avoid hitting request limits
if [[ ! -z "$1" ]]; then staging=$1; fi
echo "### Staging: $staging"

domains=(atomicoconut.com www.atomicoconut.com)
#this is used to restart the container
nginxImageTag="latest"
if [[ "$2" == "testing"  ]]; then
  domains=(testss.atomicoconut.com)
  nginxImageTag="testing"
fi

rsa_key_size=4096
data_path="/home/ec2-user"
email="maxipaolucci@gmail.com" # Adding a valid address is strongly recommended

echo "### Deleting dummy certificate for $domains ..."
docker-compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
echo

echo "### Requesting Let's Encrypt certificate for $domains ..."
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi


docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

echo "### Reloading nginx ..."
nginx_container_name=$(docker ps | grep atomic-coconut-nginx:$nginxImageTag | awk '{print $NF}')
echo "NGINX container name: $nginx_container_name"

docker exec $nginx_container_name nginx -s reload