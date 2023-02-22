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