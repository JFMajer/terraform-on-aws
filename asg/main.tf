provider "aws" {
  region = "#{AWS_REGION}#"
}

module "webserver_cluster" {
    source = "../../modules/asg/services/webserver-cluster"
    cluster_name = "webserver-cluster-#{ENV}#"
    db_address = module.mysql_rds.address
    db_port = module.mysql_rds.port
}

module "mysql_rds" {
    source = "../../modules/data-stores/mysql-rds"
    rds_suffix = "-#{ENV}#"
}