#!/bin/bash

# upload all generic nested-stacks dir to s3
aws s3 cp ./nested-stacks/ s3://maxipaolucci/cloudformation-stacks/ --recursive --sse --storage-class INTELLIGENT_TIERING

# upload atomiCoconut nested-stacks dir to s3
aws s3 cp ./nested-stacks-aco/ s3://atomicoconut/infrastructure/nested-stacks/ --recursive --sse --storage-class INTELLIGENT_TIERING

