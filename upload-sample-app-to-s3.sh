#!/bin/bash

# zip the app
cd ecs-sample; zip -r ../ecs-sample.zip * .ebext*
cd ..

# upload zip to S3
aws s3 cp ./ecs-sample.zip s3://atomicoconut/infrastructure/ecs-sample.zip --sse --storage-class INTELLIGENT_TIERING

# remove zipped app
rm ecs-sample.zip