data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

data "terraform_remote_state" "mysql_rds" {
    backend = "s3"
    config = {
        bucket = "#{S3_BUCKET}#"
        key = "asg/data-stores/mysql-rds/terraform.tfstate"
        region = "#{AWS_REGION}#"
        dynamodb_table = "#{DYNAMO_TABLE}#"
        encrypt = true
    }
}

resource "aws_launch_configuration" "asg_lc" {
  name_prefix   = "${var.cluster_name}-lc-"
  image_id      = "ami-09e1162c87f73958b"
  instance_type = "t3.micro"
  spot_price = "0.0108"
  security_groups = [aws_security_group.asg_sg.id]

  user_data = templatefile("user-data.sh", {
    server_port = var.server_port,
    db_address = var.db_address,
    db_port = var.db_port
  })

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group" "asg_sg" {
    name = "${var.cluster_name}-tg-sg"
    description = "Allow HTTP traffic from load balancer"
    vpc_id = data.aws_vpc.default.id

    ingress {
        description = "HTTP"
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        security_groups = [aws_security_group.asg_lb_sg.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_autoscaling_group" "asg" {
  name_prefix = "${var.cluster_name}-asg-"
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
  name               = "${var.cluster_name}-alb"
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
  name        = "${var.cluster_name}-alb-sg"
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
  name     = "${var.cluster_name}-tg"
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

