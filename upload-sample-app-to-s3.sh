#!/bin/bash

# zip the app including .ebext* and .plat* dirs
cd ecs-sample; zip -r ../ecs-sample.zip * .ebext* .plat*
cd ..

# upload zip to S3
aws s3 cp ./ecs-sample.zip s3://atomicoconut/infrastructure/ecs-sample.zip --sse --storage-class INTELLIGENT_TIERING

# remove zipped app
rm ecs-sample.zip