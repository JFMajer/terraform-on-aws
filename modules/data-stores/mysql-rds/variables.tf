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

variable "rds_suffix" {
    description = "Suffix to append to the RDS instance name"
    type        = string
}

variable "cluster_name" {
    description = "Name of the cluster"
    type        = string
}

variable "subnet_ids" {
    description = "Subnet IDs to use for the RDS instance"
    type = list(string)
}