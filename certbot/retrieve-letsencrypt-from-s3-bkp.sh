#!/bin/bash

# capture environment parameter if present
environment="" # Set to "testing" if you're in testing env
nginxImageTag=""
if [[ ! -z "$1" ]]; then
	environment="-$1";
	nginxImageTag=$1;
fi
echo "### Retrieving bkp from Environment: atomiCoconut$environment"

if [[ -z "$2" ]]; then
	  echo "Usage: retrieve-letsencrypt-from-s3-bkp.sh [ENVIRONMENT] [BKP_DATE]"
  	echo -e "Parameters: \n\t ENVIRONMENT: use \"\" for production \n\t BKP_DATE: format as YYMMDD \n"
  	exit 1;
fi

aws s3 cp s3://elasticbeanstalk-ap-southeast-2-782522910439/atomiCoconut$environment/certbot_certs_backups/certbot-certs-$2.tar.gz .

tar xvfz certbot-certs-$2.tar.gz

rm certbot-certs-$2.tar.gz


echo
echo
./reload_nginx.sh $nginxImageTag
