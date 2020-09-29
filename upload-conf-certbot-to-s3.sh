#!/bin/bash

# zip the dir
cd certbot; zip -r ../conf-certbot.zip *
cd ..

# upload zip to S3
aws s3 cp ./conf-certbot.zip s3://atomicoconut/infrastructure/conf-certbot.zip --sse --storage-class INTELLIGENT_TIERING

# remove zipped file
rm conf-certbot.zip