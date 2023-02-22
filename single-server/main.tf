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
  ami           = "ami-09e1162c87f73958b"
  instance_type = "t3.micro"

  tags = {
    Name = "terraform-example"
  }
}