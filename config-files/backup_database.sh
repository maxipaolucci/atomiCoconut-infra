#!/bin/bash

#!/bin/bash
# ------------------------------------------------------------------
# [Author] Title
#          Description
# ------------------------------------------------------------------

VERSION=0.1.0
SUBJECT=backup_database

function print_usage()
{
    echo "Usage: backup_database.sh [-h] BUCKET_NAME ENVIRONMENT"
  	echo -e "Parameters: \n\t BUCKET_NAME: the s3 bucket where to store the backups \n\t ENVIRONMENT: use \"\" for production \n"
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
if [[ ! -z "$param2" ]]; then environment="-$param2"; fi
echo "### Environment: $environment"

# set proper image tag
imageTag="latest"
if [[ ! -z "$param2" ]]; then
	imageTag=$param2
fi

# get server container name
server_container_name=$(docker ps | grep atomic-coconut-server:$imageTag | awk '{print $NF}')
echo "Server container name: $server_container_name"
# run db backup in server container. This will run the npm command an generate a db bkp in /app/data/dev directory
docker exec -it $server_container_name npm run dumpData

# get the current backup counter from this file to name the backup
CURRENT_DB_BKP=$(cat current_bkp_counter)

# compress conf directory in a tar.gz file with today date
sudo tar -czvf backup-$CURRENT_DB_BKP.tar.gz db-bkp

# backup/upload tar files to S3 bucket (sse AES256 encryption and intelligent tiering)
aws s3 cp ./backup-$CURRENT_DB_BKP.tar.gz s3://$param1/atomiCoconut$environment/database_backups/backup-$CURRENT_DB_BKP.tar.gz --sse --storage-class INTELLIGENT_TIERING
# tag latest
aws s3 cp ./backup-$CURRENT_DB_BKP.tar.gz s3://$param1/atomiCoconut$environment/database_backups/backup-latest.tar.gz --sse --storage-class INTELLIGENT_TIERING

# remove local tar.gz file already backup
sudo rm -f backup-$CURRENT_DB_BKP.tar.gz

# increment or reset backup counter
MAX_DB_BKP_KEPT=`sudo /opt/elasticbeanstalk/bin/get-config environment | jq .MAX_DB_BKP_KEPT | tr -d '"'`
if [[ "$CURRENT_DB_BKP" -eq "$MAX_DB_BKP_KEPT" ]]; then
  CURRENT_DB_BKP=1
else
  let CURRENT_DB_BKP+=1
fi
# store the counter in the file
echo "$CURRENT_DB_BKP" > current_bkp_counter

