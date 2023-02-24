resource "aws_db_instance" "rds_mysql" {
    name = "rds-mysql${var.rds_suffix}"
    allocated_storage = 20
    engine = "mysql"
    instance_class = "db.t3.micro"
    skip_final_snapshot = true
    db_name = "terraform_db"

    username = var.rds_username
    password = var.rds_password
}