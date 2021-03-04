variable "aws_region" {
  default = "ap-southeast-2"
}

variable "environment" {
  default = "testing"
  description = "ElasticBeanstalk environment type"
}

variable "app_name" {
  default = "atomiCoconut"
  description = "ElasticBeanstalk application name"
}

variable "eb_app_source_s3_bucket_name" {
  default = "atomicoconut"
  description = "Bucket with initial app-sources to deploy in the EB environment"
}

variable "eb_app_source_s3_key_name" {
  default = "infrastructure/ecs-sample.zip"
  description = "Key in S3 Bucket with initial app-sources to deploy in the EB environment"
}

variable "eb_enable_ec2_spot_instances" {
  default = true
  type = bool
  description = "Set to true to use EC2 spot intance in EB environment, or false for on demmand instances"
}
variable "deploy_https_certs_from_bkp" {
  default = true
  type = bool
  description = "Set to true to allow deployment of the latest certificates backed up in S3 for this environment"
}

variable "aco_ec2_key_name" {
  default = "atomiCoconut_keypair"
  description = "Keypair for elasticbeanstalk environment to connect to EC2 instances"
}

variable "eb_sns_topic_email" {
  default = "maxipaolucci@gmail.com"
  description = "Email where to receive notifications regarding ElasticBeanstalk environment"
}

variable "max_db_bkp_kept" {
  default = 30
  type = number
  description = "Maximum amount of database backups to keep in S3"
}