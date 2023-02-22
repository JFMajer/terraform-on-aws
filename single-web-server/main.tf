terraform {
  backend "s3" {
    bucket = "#{S3_BUCKET}#"
    key    = "terraform.tfstate"
    region = "#{AWS_REGION}#"
    dynamodb_table = "#{DYNAMO_TABLE}#"
    encrypt = true
  }
}

provider "aws" {
  region = "#{AWS_REGION}#"
}
  
resource "aws_instance" "example" {
  ami           = "ami-0bb935e4614c12d86"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p 8080 &
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
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
}
}