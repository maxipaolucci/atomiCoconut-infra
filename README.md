# atomiCoconut-infra
Infrastructure resources for atomiCoconut

## in order to deploy

1) In your local terminal run: 
  1.a) >`./upload-sample-app-to-s3.sh` (only when changes are added to the ecs-sample dir)
  1.b) >`./upload-conf-certbot-to-s3.sh` (only when changes are added to the certbot dir)
  1.c) >`./upload-config-files-to-s3.sh` (only when changes are added to the config-files dir)
  1.c) >`./upload-nested-stacks-to-s3.sh` (only when changes are added to the nested-stacks or nested-stacks-aco dirs)
  or just: >`./upload-all-to-s3.sh` (to upload the all of the above)
2) Cloudformation: Create a new stack with elastic-beanstalk-aco-env.yml
2.1) Create all the required parameters in AWS SSM 

