# Cloudwath group to see container logs of the app
##################################################
resource "aws_cloudwatch_log_group" "ec2_containers" {
  name = "aco-${var.environment}-containers-logs"
  retention_in_days = 14
}

# SNS Topic to send notifications when container logs metrics fire an alarm
####################################################
resource "aws_sns_topic" "container_errors" {
  name = "${var.app_name}-${var.environment}-errors-cloudwatch-alarm"
}

# resource "aws_sns_topic_subscription" "container_errors" {
#   topic_arn = aws_sns_topic.container_errors.arn
#   protocol  = "email"
#   endpoint  = var.eb_sns_topic_email
# }