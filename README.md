# atomiCoconut-infra
Infrastructure resources for atomiCoconut

## in order to deploy

1) In your local terminal run: 
  1.a) `>./upload-sample-app-to-s3.sh` (only when changes are added to the ecs-sample dir)
  1.a) `>./upload-conf-certbot-to-s3.sh` (only when changes are added to the certbot dir)
2) Cloudformation: Create a new stack with elastic-beanstalk-aco-env.yml
2.1) Create all the required parameters in AWS SSM 
