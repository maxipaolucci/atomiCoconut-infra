# ElasticBeanstalk Application: atomiCoconut-ENVIRONMENT
######################################################

resource "aws_elastic_beanstalk_application" "aco_elasticbeanstalk_application" {
  name        = "${var.app_name}-${var.environment}"
  description = "This is the ${var.environment} application"

  appversion_lifecycle {
    service_role          = aws_iam_role.aco_elasticbeanstalk_service_role.arn
    max_count             = 100
    delete_source_from_s3 = true
  }
}


# ElasticBeanstalk Application Version: elasticbeanstalk_initial_application_version-ENVIRONMENT
######################################################

data "aws_s3_bucket" "eb_app_source" {
  bucket = var.eb_app_source_s3_bucket_name
}

resource "aws_elastic_beanstalk_application_version" "elasticbeanstalk_initial_app_version" {
  name        = "elasticbeanstalk_initial_app_version_${var.environment}"
  application = aws_elastic_beanstalk_application.aco_elasticbeanstalk_application.name
  description = "Initial application version created for ${var.environment}"
  bucket      = data.aws_s3_bucket.eb_app_source.id
  key         = var.eb_app_source_s3_key_name
}


# ElasticBeanstalk Environment
###############################

resource "aws_elastic_beanstalk_environment" "elasticbeanstalk_environment" {
  name                = "${var.app_name}-env-${var.environment}"
  description = "AWS Elastic Beanstalk Environment for ${var.environment}"
  application         = aws_elastic_beanstalk_application.aco_elasticbeanstalk_application.name
  solution_stack_name = "64bit Amazon Linux 2 v3.2.0 running Docker"
  version_label = aws_elastic_beanstalk_application_version.elasticbeanstalk_initial_app_version.name

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.aco_elasticbeanstalk_service_role.name
  }

  setting {
    namespace = "aws:ec2:instances"
    name      = "InstanceTypes"
    value     = "t2.micro"
  }

  setting {
    namespace = "aws:ec2:instances"
    name      = "EnableSpot"
    value     = var.eb_enable_ec2_spot_instances
  }

  setting {
    namespace = "aws:ec2:instances"
    name      = "SpotFleetOnDemandBase"
    value     = var.eb_enable_ec2_spot_instances ? 0 : 1
  }
  
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.aco_instance_profile_elasticbeanstalk_ec2_role.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.atomicoconut_security_group.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = var.aco_ec2_key_name
  }
}

output "aco_elasticbeanstalk_url" {
  value = aws_elastic_beanstalk_environment.elasticbeanstalk_environment.endpoint_url
}