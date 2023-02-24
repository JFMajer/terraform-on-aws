resource "aws_db_instance" "rds_mysql" {
    #identifier = "mysql-rds${var.rds_suffix}"
    allocated_storage = 20
    engine = "mysql"
    instance_class = "db.t3.micro"
    skip_final_snapshot = true
    db_name = "terraform_db"
    apply_immediately = true

    username = var.rds_username
    password = var.rds_password
}