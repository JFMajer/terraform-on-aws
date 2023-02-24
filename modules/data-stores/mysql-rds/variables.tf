variable "rds_username" {
    description = "The username for the RDS instance"
    type = string
    sensitive = true
}

variable "rds_password" {
    description = "The password for the RDS instance"
    type = string
    sensitive = true
}