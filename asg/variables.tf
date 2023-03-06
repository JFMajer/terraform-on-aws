variable "cluster_name" {
    description = "Name of the cluster"
    type        = string
    default = "app1-cluster-#{ENV}#"
}

variable "rds_suffix" {
    description = "Suffix to append to the RDS instance name"
    type        = string
    default = "-#{ENV}#"
}

variable "rds_username" {
    description = "The username for the RDS instance"
    type = string
    sensitive = true
    default = "#{RDS_USER}#"
}

variable "rds_password" {
    description = "The password for the RDS instance"
    type = string
    sensitive = true
    default = "#{RDS_PASSWORD}#"
}

variable "custom_tags" {
    description = "Custom tags to add to the resources"
    type = map(string)
    default = {}
}

variable "subdomain" {
    description = "Subdomain for webserver cluster"
    type = string
    default = "asg-#{ENV}#"
}