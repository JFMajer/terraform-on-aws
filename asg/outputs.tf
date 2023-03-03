output "load_balancer_dns" {
    value = module.webserver_cluster.load_balancer_dns
}

output "load_balancer_url" {
    value = module.webserver_cluster.http_url
}

output "fqdn_r53" {
    value = "http://${aws_route53_record.alb_domain.name}.heheszlo.com"
}