provider "aws" {
  region = "#{AWS_REGION}#"

  default_tags {
    tags = {
      Environment = "#{ENV}#"
      ManagedBy = "terraform"
    }
  }
}

module "webserver_cluster" {
    source = "git::github.com/JFMajer/terraform-aws-asg-module?ref=v0.1.3"
    cluster_name = var.cluster_name
    db_address = module.mysql_rds.address
    db_port = module.mysql_rds.port
    server_text = "Hello World!"

    custom_tags = {
        Owner = "team-foo"
        Environment = "#{ENV}#"
        ManagedBy = "terraform"
    }
}

module "mysql_rds" {
    source = "../modules/data-stores/mysql-rds"
    rds_suffix = var.rds_suffix
    rds_username = var.rds_username
    rds_password = var.rds_password
    cluster_name = var.cluster_name
    subnet_ids = module.vpc.private_subnets_ids
}

module "vpc" {
  source = "git::github.com/JFMajer/terraform-aws-vpc-module?ref=v0.0.4"
  vpc_cidr = "10.0.0.0/16"
  public_subnets_count = 3
  private_subnets_count = 3
}