#!/bin/bash
# ------------------------------------------------------------------
# [Author] Title
#          Description
# ------------------------------------------------------------------

VERSION=0.1.0
SUBJECT=request-letsencrypt-certs

function print_usage()
{
    echo "Usage: request-letsencrypt-certs.sh [-h] STAGING ENVIRONMENT"
  	echo -e "Parameters: \n\t STAGING: 1 for test letsencrypt api, 0 for real action \n\t ENVIRONMENT: use \"\" for production or \"testing\" for testing environment\n"
    echo -e "\n Use -h for help"
}

# --- Options processing -------------------------------------------
if [ $# == 0 ] ; then
    print_usage
    exit 1;
fi

while getopts ":vh" optname
  do
    case "$optname" in
      "v")
        echo "Version $VERSION"
        exit 0;
        ;;
      # "i")
      #   echo "-i argument: $OPTARG"
      #   ;;
      "h")
        print_usage
        exit 0;
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 0;
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 0;
        ;;
      *)
        echo "Unknown error while processing options"
        exit 0;
        ;;
    esac
  done

shift $(($OPTIND - 1))

param1=$1
param2=$2

# --- Locks -------------------------------------------------------
LOCK_FILE=/tmp/$SUBJECT.lock
if [ -f "$LOCK_FILE" ]; then
   echo "Script is already running"
   exit
fi

trap "rm -f $LOCK_FILE" EXIT
touch $LOCK_FILE

# --- Body --------------------------------------------------------
staging=1 # Set to 1 if you're testing your setup to avoid hitting request limits
if [[ ! -z "$param1" ]]; then staging=$param1; fi
echo "### Staging: $staging"

domains=(atomicoconut.com www.atomicoconut.com)
if [[ "$param2" == "testing"  ]]; then
  domains=(testingss.atomicoconut.com)
fi

#this is used to restart nginx the container to reload the certs
nginxImageTag=""
if [[ ! -z "$param2" ]]; then
	nginxImageTag=$param2;
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
echo
./reload_nginx.sh $nginxImageTag

echo 
echo
./start_certbot_renew.sh
# -----------------------------------------------------------------