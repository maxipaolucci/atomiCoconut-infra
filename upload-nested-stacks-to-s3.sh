#!/bin/bash

# upload all in nested-stacks dir to s3
aws s3 cp ./nested-stacks/ s3://maxipaolucci/cloudformation-stacks/ --recursive --sse --storage-class INTELLIGENT_TIERING

