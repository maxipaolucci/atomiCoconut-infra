# IAM Role: aco-ENVIRONMENT-elasticbeanstalk-service-role
###########################################################

data "aws_iam_policy" "eb_enhanced_health_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

data "aws_iam_policy" "eb_service_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

data "aws_iam_policy_document" "aco_elasticbeanstalk_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["elasticbeanstalk.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        "elasticbeanstalk"
      ]
    }
  }
}

resource "aws_iam_role" "aco_elasticbeanstalk_service_role" {
  name = "aco-${var.environment}-elasticbeanstalk-service-role"
  assume_role_policy = data.aws_iam_policy_document.aco_elasticbeanstalk_assume_role_policy.json
  # managed_policy_arns = [data.aws_iam_policy.eb_enhanced_health_policy.arn] # for some reason does not work, using instead the aws_iam_policy_attachment below
  max_session_duration = 3600
  path = "/"
  tags = {
    "ENVIRONMENT" = var.environment
    "APP_NAME" = var.app_name
  }
}

resource "aws_iam_policy_attachment" "aco_elasticbeanstalk_service_role__eb_enhanced_health_policy__attachment" {
  name       = "aco_elasticbeanstalk_service_role__eb_enhanced_health_policy__attachment"
  roles      = [aws_iam_role.aco_elasticbeanstalk_service_role.name]
  policy_arn = data.aws_iam_policy.eb_enhanced_health_policy.arn
}

resource "aws_iam_policy_attachment" "aco_elasticbeanstalk_service_role__eb_service_policy__attachment" {
  name       = "aco_elasticbeanstalk_service_role__eb_service_policy__attachment"
  roles      = [aws_iam_role.aco_elasticbeanstalk_service_role.name]
  policy_arn = data.aws_iam_policy.eb_service_policy.arn
}


# IAM Role: aco-ENVIRONMENT-elasticbeanstalk-ec2-role
######################################################

data "aws_iam_policy" "cloud_watch_agent_admin_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
}

data "aws_iam_policy" "amazon_s3_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

data "aws_iam_policy" "aws_elasticbeanstalk_web_tier" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

data "aws_iam_policy" "aws_elasticbeanstalk_multicontainer_docker" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

data "aws_iam_policy" "aws_elasticbeanstalk_worker_tier" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

data "aws_iam_policy_document" "aco_ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aco_elasticbeanstalk_ec2_role" {
  name = "aco-${var.environment}-elasticbeanstalk-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.aco_ec2_assume_role_policy.json
  max_session_duration = 3600
  path = "/"
  tags = {
    "ENVIRONMENT" = var.environment
    "APP_NAME" = var.app_name
  }
}

resource "aws_iam_policy_attachment" "aco_elasticbeanstalk_ec2_role__cloud_watch_agent_admin_policy__attachment" {
  name       = "aco_elasticbeanstalk_ec2_role__cloud_watch_agent_admin_policy__attachment"
  roles      = [aws_iam_role.aco_elasticbeanstalk_ec2_role.name]
  policy_arn = data.aws_iam_policy.cloud_watch_agent_admin_policy.arn
}

resource "aws_iam_policy_attachment" "aco_elasticbeanstalk_ec2_role__amazon_s3_full_access__attachment" {
  name       = "aco_elasticbeanstalk_ec2_role__amazon_s3_full_access__attachment"
  roles      = [aws_iam_role.aco_elasticbeanstalk_ec2_role.name]
  policy_arn = data.aws_iam_policy.amazon_s3_full_access.arn
}

resource "aws_iam_policy_attachment" "aco_elasticbeanstalk_ec2_role__aws_elasticbeanstalk_web_tier__attachment" {
  name       = "aco_elasticbeanstalk_ec2_role__aws_elasticbeanstalk_web_tier__attachment"
  roles      = [aws_iam_role.aco_elasticbeanstalk_ec2_role.name]
  policy_arn = data.aws_iam_policy.aws_elasticbeanstalk_web_tier.arn
}

resource "aws_iam_policy_attachment" "aco_elasticbeanstalk_ec2_role__aws_elasticbeanstalk_multicontainer_docker__attachment" {
  name       = "aco_elasticbeanstalk_ec2_role__aws_elasticbeanstalk_multicontainer_docker__attachment"
  roles      = [aws_iam_role.aco_elasticbeanstalk_ec2_role.name]
  policy_arn = data.aws_iam_policy.aws_elasticbeanstalk_multicontainer_docker.arn
}

resource "aws_iam_policy_attachment" "aco_elasticbeanstalk_ec2_role__aws_elasticbeanstalk_worker_tier__attachment" {
  name       = "aco_elasticbeanstalk_ec2_role__aws_elasticbeanstalk_worker_tier__attachment"
  roles      = [aws_iam_role.aco_elasticbeanstalk_ec2_role.name]
  policy_arn = data.aws_iam_policy.aws_elasticbeanstalk_worker_tier.arn
}


# IAM Instance profile for eb ec2 role
#######################################

resource "aws_iam_instance_profile" "aco_instance_profile_elasticbeanstalk_ec2_role" {
  name = "aco-${var.environment}-instance-profile-elasticbeanstalk-ec2-role"
  role = aws_iam_role.aco_elasticbeanstalk_ec2_role.name
  path = "/"
}
