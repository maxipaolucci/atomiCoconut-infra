#!/bin/bash

# zip the dir
cd config-files; zip -r ../config-files.zip *
cd ..

# upload zip to S3
aws s3 cp ./config-files.zip s3://atomicoconut/infrastructure/config-files.zip --sse --storage-class INTELLIGENT_TIERING

# remove zipped file
rm config-files.zip