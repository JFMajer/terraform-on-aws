variable "cluster_name" {
    description = "Name of the cluster"
    type        = string
    default = "webserver-cluster"
}

variable "rds_suffix" {
    description = "Suffix to append to the RDS instance name"
    type        = string
}