terraform {
  backend "s3" {
    bucket = "#{S3_BUCKET}#"
    key    = "asg/services/webserver-cluster/terraform.tfstate"
    region = "#{AWS_REGION}#"
    dynamodb_table = "#{DYNAMO_TABLE}#"
    encrypt = true
  }
}