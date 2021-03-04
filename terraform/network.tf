data "aws_vpc" "default" {
  default = true
}

# Security group for Elastic Beanstalk environment
##################################################
resource "aws_security_group" "atomicoconut_security_group" {
  name        = "atomiCoconut-${var.environment}-SecurityGroup"
  description = "Security Group for elasticbeanstalk ${var.environment} environment - ${var.app_name}"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "TLS IPv4"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "TLS IPv6"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    NAME = "${var.app_name}-security-group"
  }
}

# Route 53 record to point to Elastic Beanstalk
################################################

data "aws_route53_zone" "atomicoconut" {
  name         = "atomicoconut.com."
}

resource "aws_route53_record" "r53_to_elastic_beanstalk_dns_record" {
  zone_id = data.aws_route53_zone.atomicoconut.zone_id
  name    = var.environment == "production" ? "atomicoconut.com" : "${var.environment}ss.atomicoconut.com"
  type    = "A"
  ttl     = "3600"
  records = [aws_elastic_beanstalk_environment.elasticbeanstalk_environment.endpoint_url]
}