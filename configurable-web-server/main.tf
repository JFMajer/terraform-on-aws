terraform {
  backend "s3" {
    bucket = "#{S3_BUCKET}#"
    key    = "single-web-server/terraform.tfstate"
    region = "#{AWS_REGION}#"
    dynamodb_table = "#{DYNAMO_TABLE}#"
    encrypt = true
  }
}

provider "aws" {
  region = "#{AWS_REGION}#"
}
  
resource "aws_instance" "example" {
  ami           = "ami-09e1162c87f73958b"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p ${var.server_port} &
    EOF

  user_data_replace_on_change = true

  tags = {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
    name        = "terraform-example"
    description = "Allow HTTP traffic"
    
    ingress {
        description = "HTTP"
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

variable "server_port" {
    description = "The port the web server will listen on"
    type = number
    default = 8080
}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "The public IP address of the web server"
}