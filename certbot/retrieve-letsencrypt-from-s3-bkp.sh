#!/bin/bash
# ------------------------------------------------------------------
# [Author] Title
#          Description
# ------------------------------------------------------------------

VERSION=0.1.0
SUBJECT=retrieve-letsencrypt-from-s3-bkp

function print_usage()
{
    echo "Usage: retrieve-letsencrypt-from-s3-bkp.sh [-h] ENVIRONMENT BKP_DATE"
  	echo -e "Parameters: \n\t ENVIRONMENT: use \"\" for production \n\t BKP_DATE: format as YYMMDD \n"
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
# capture environment parameter if present
environment="" # Set to "testing" if you're in testing env
nginxImageTag="" # this is used to restart the nginx container to reload the certs
if [[ ! -z "$param1" ]]; then
	environment="-$param1";
	nginxImageTag=$param1;
fi
echo "### Retrieving bkp from Environment: atomiCoconut$environment"

if [[ -z "$param2" ]]; then
	  print_usage
  	exit 0;
fi

aws s3 cp s3://elasticbeanstalk-ap-southeast-2-782522910439/atomiCoconut$environment/certbot_certs_backups/certbot-certs-$param2.tar.gz .

tar xvfz certbot-certs-$param2.tar.gz

rm certbot-certs-$param2.tar.gz


echo
echo
./reload_nginx.sh $nginxImageTag

echo 
echo
./start_certbot_renew.sh

# -----------------------------------------------------------------