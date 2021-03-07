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

  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Endpoint"
    value     = var.eb_sns_topic_email
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "CURRENCYLAYER_KEY"
    value     = data.aws_ssm_parameter.currency_layer_key.value
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MAPS_API_KEY"
    value     = data.aws_ssm_parameter.maps_api_key.value
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SESSION_DURATION_SECONDS"
    value     = 86400
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SESSION_KEY"
    value     = data.aws_ssm_parameter.nodejs_session_key.value
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SESSION_SECRET"
    value     = data.aws_ssm_parameter.nodejs_session_secret.value
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PUSHER_SECRET"
    value     = data.aws_ssm_parameter.pusher_secret.value
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PUSHER_APP_ID"
    value     = data.aws_ssm_parameter.pusher_app_id.value
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PUSHER_CLUSTER"
    value     = "ap4"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PUSHER_KEY"
    value     = data.aws_ssm_parameter.pusher_key.value
  }
  setting {
    # nodejs api listening port
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PORT"
    value     = 7777
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MAX_DB_BKP_KEPT"
    value     = var.max_db_bkp_kept
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MAIL_TRAP_PASS"
    value     = var.environment == "production" ? "" : data.aws_ssm_parameter.mailtrap_pass.value
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MAIL_TRAP_USER"
    value     = var.environment == "production" ? "" : data.aws_ssm_parameter.mailtrap_user.value
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MAIL_TRAP_PORT"
    value     = var.environment == "production" ? "" : 2525
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "MAIL_TRAP_HOST"
    value     = var.environment == "production" ? "" : "smtp.mailtrap.io"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE"
    value     = data.aws_ssm_parameter.database.value
  }
  setting {
    # this is for the nodejs server
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "NODE_ENV"
    value     = var.environment
  }
  setting {
    # This setting will be used to execute some commands defined in ebextensions files in initial sample app
    # For production we want to pass an empty value
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ENVIRONMENT_TYPE"
    value     = var.environment == "production" ? "" : var.environment
  }
  setting {
    # This setting will be used to execute some commands defined in ebextensions files in initial sample app
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DEPLOY_HTTPS_CERTS_FROM_BKP"
    value     = var.deploy_https_certs_from_bkp
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SENDGRID_API_KEY"
    value     = var.environment == "production" ? data.aws_ssm_parameter.sendgrid_api_key.value : ""
  }
}

output "aco_elasticbeanstalk_url" {
  value = aws_elastic_beanstalk_environment.elasticbeanstalk_environment.endpoint_url
}