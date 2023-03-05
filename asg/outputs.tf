output "load_balancer_dns" {
    value = module.alb.load_balancer_dns
}

output "load_balancer_url" {
    value = module.alb.http_url
}

output "fqdn_r53" {
    value = "http://${aws_route53_record.alb_domain.name}.heheszlo.com"
}

output "fqdn_r53_https" {
    value = "https://${aws_route53_record.alb_domain.name}.heheszlo.com"
}

output primary_db_endpoint {
    value = module.mysql_rds.address
}

output replica_db_endpoint {
    value = module.mysql_replica.address
}