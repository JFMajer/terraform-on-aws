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
    source = "git::github.com/JFMajer/terraform-aws-asg-module?ref=v0.1.5"
    cluster_name = var.cluster_name
    db_address = module.mysql_rds.address
    db_port = module.mysql_rds.port
    server_text = "Hello World!"
    asg_subnets = module.vpc.private_subnets_ids
    alb_subnets = module.vpc.public_subnets_ids
    vpc_id = module.vpc.vpc_id
    scale_in_at_night = true

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