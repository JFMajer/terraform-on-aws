output "load_balancer_dns" {
    value = module.webserver_cluster.load_balancer_dns
}

output "load_balancer_url" {
    value = module.webserver_cluster.http_url
}