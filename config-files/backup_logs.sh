#!/bin/bash

#!/bin/bash
# ------------------------------------------------------------------
# [Author] Title
#          Description
# ------------------------------------------------------------------

VERSION=0.1.0
SUBJECT=backup_logs

function print_usage()
{
    echo "Usage: backup_logs.sh [-hv] BUCKET_NAME ENVIRONMENT"
  	echo -e "Parameters: bucket \n\t BUCKET_NAME: the bucket name in S3 \n\t ENVIRONMENT: use \"\" for production \n"
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

bucketName=$1
environment=$2


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
environmentName="" # Set to "testing" if you're in testing env
if [[ ! -z "$environment" ]]; then environmentName="-$environment"; fi
echo "### Environment: $environment"


# upload log file to S3 bucket (sse AES256 encryption and intelligent tiering)
aws s3 mv ./logs-bkp/ s3://$bucketName/atomiCoconut$environmentName/logs/ --recursive --sse --storage-class INTELLIGENT_TIERING
