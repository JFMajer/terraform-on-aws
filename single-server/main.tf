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

  tags = {
    Name = "terraform-example"
  }
}