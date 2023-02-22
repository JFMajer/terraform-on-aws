terraform {
  backend "s3" {
    bucket = "#{S3_BUCKET}#"
    key    = "asg/terraform.tfstate"
    region = "#{AWS_REGION}#"
    dynamodb_table = "#{DYNAMO_TABLE}#"
    encrypt = true
  }
}

provider "aws" {
  region = "#{AWS_REGION}#"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

resource "aws_launch_configuration" "asg_lc" {
  name_prefix   = "asg-lc-"
  image_id      = "ami-09e1162c87f73958b"
  instance_type = "t3.micro"
  spot_price = "0.0108"

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p ${var.server_port} &
    EOF

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "asg" {
  name_prefix = "asg-"
  min_size = 2
  max_size = 5
  desired_capacity = 2
  launch_configuration = aws_launch_configuration.asg_lc.name
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns = [aws_lb_target_group.asg_tg.arn]
  health_check_type = "ELB"
  health_check_grace_period = 300 

    tag {
        key = "Name"
        value = "asg"
        propagate_at_launch = true
    }
}

resource "aws_lb" "asg_lb" {
  name               = "asg-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.asg_lb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.asg_lb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "Hello, World"
            status_code  = "200"
        }
    }
}

resource "aws_lb_listener_rule" "asg_lb_listener_rule" {
    listener_arn = aws_lb_listener.http.arn
    priority     = 100

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.asg_tg.arn
    }

    condition {
        path_pattern {
            values = ["*"]
        }
    }
}

resource "aws_security_group" "asg_lb_sg" {
  name        = "asg-lb-sg"
  description = "Allow HTTP traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_lb_target_group" "asg_tg" {
  name     = "asg-tg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

    health_check {
        path = "/"
        port = var.server_port
        protocol = "HTTP"
        matcher = "200"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}




variable "server_port" {
    description = "The port the web server will listen on"
    type = number
    default = 8080
}

output "load_balancer_dns" {
  value = aws_lb.asg_lb.dns_name
  description = "DNS name of the load balancer"
}

output http_url {
  value = "http://${aws_lb.asg_lb.dns_name}"
}