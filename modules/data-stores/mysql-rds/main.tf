resource "aws_db_instance" "rds_mysql" {
    identifier = "rds-mysql-${var.cluster_name}-${random_string.random.result}"
    allocated_storage = 20
    engine = "mysql"
    instance_class = "db.t3.micro"
    skip_final_snapshot = true
    db_name = "terraform_db"
    apply_immediately = true
    db_subnet_group_name = aws_db_subnet_group.rds_mysql.name

    username = var.rds_username
    password = var.rds_password

}


# Generate random string without any special characters, all lowercase
resource "random_string" "random" {
    length = 4
    special = false
    upper = false
}

resource "aws_db_subnet_group" "rds_mysql" {
    name = "rds-mysql-${var.cluster_name}-subnetgroup"
    subnet_ids = var.subnet_ids
}