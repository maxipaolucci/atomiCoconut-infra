locals {
  environment = var.environment == "testing" ? "test" : var.environment
}

data "aws_ssm_parameter" "currency_layer_key" {
  name = "/maxipaolucci/currencylayer/key"
}

data "aws_ssm_parameter" "maps_api_key" {
  name = "/maxipaolucci/aco/maps/apikey"
}

data "aws_ssm_parameter" "pusher_secret" {
  name = "/maxipaolucci/aco/${local.environment}/pusher/secret"
}

data "aws_ssm_parameter" "pusher_key" {
  name = "/maxipaolucci/aco/${local.environment}/pusher/key"
}

data "aws_ssm_parameter" "pusher_app_id" {
  name = "/maxipaolucci/aco/${local.environment}/pusher/appid"
}

data "aws_ssm_parameter" "nodejs_session_key" {
  name = "/aco/nodesession/key"
}

data "aws_ssm_parameter" "nodejs_session_secret" {
  name = "/aco/nodesession/secret"
}

data "aws_ssm_parameter" "mailtrap_pass" {
  name = "/maxipaolucci/aco/mailtrap/pass"
}

data "aws_ssm_parameter" "mailtrap_user" {
  name = "/maxipaolucci/aco/mailtrap/user"
}

data "aws_ssm_parameter" "database" {
  name = "/maxipaolucci/aco/${local.environment}/atlasdb/connectionstring"
}

data "aws_ssm_parameter" "sendgrid_api_key" {
  name = "/maxipaolucci/aco/sendgrid/apikey"
}
