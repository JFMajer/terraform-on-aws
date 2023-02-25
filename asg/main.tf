provider "aws" {
  region = "#{AWS_REGION}#"
}

module "webserver_cluster" {
    source = "github.com/JFMajer/terraform-aws-asg?ref=v0.0.1"
    cluster_name = var.cluster_name
    db_address = module.mysql_rds.address
    db_port = module.mysql_rds.port
}

module "mysql_rds" {
    source = "../modules/data-stores/mysql-rds"
    rds_suffix = var.rds_suffix
    rds_username = var.rds_username
    rds_password = var.rds_password
    cluster_name = var.cluster_name
}