data "aws_vpc" "default" {
  default = true
}

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