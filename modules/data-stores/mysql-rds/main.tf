terraform {
  backend "s3" {
    bucket = "#{S3_BUCKET}#"
    key    = "asg/data-stores/mysql-rds/terraform.tfstate"
    region = "#{AWS_REGION}#"
    dynamodb_table = "#{DYNAMO_TABLE}#"
    encrypt = true
  }
}


resource "aws_db_instance" "rds_mysql" {
    identifier_prefix = "terraform-aws"
    allocated_storage = 20
    engine = "mysql"
    instance_class = "db.t3.micro"
    skip_final_snapshot = true
    db_name = "terraform_db"

    username = var.rds_username
    password = var.rds_password
}