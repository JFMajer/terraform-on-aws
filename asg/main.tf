provider "aws" {
  region = "#{AWS_REGION}#"
  assume_role {
    role_arn = "#{AWS_ROLE_TO_ASSUME}#"
  }
  default_tags {
    tags = {
      Environment = "#{ENV}#"
      ManagedBy = "terraform"
    }
  }
}

provider "aws" {
  alias = "dns"
  region = "#{AWS_REGION}#"
  assume_role {
    role_arn = "#{AWS_ROUTE53_ROLE}#"
  }
}

module "webserver_cluster" {
    source = "git::github.com/JFMajer/terraform-aws-asg-module?ref=v0.0.1"
    cluster_name = var.cluster_name
    db_address = module.mysql_rds.address
    db_port = module.mysql_rds.port
    server_text = "Testing lifecycle"
    asg_subnets = module.vpc.private_subnets_ids
    alb_subnets = module.vpc.public_subnets_ids
    vpc_id = module.vpc.vpc_id
    scale_in_at_night = true
    certificate_arn = aws_acm_certificate.alb_cert.arn

    custom_tags = {
        Owner = "team-foo"
        Environment = "#{ENV}#"
        ManagedBy = "terraform"
    }
}

module "mysql_rds" {
    source = "../modules/data-stores/mysql-rds"
    rds_suffix = var.rds_suffix
    rds_username = var.rds_username
    rds_password = var.rds_password
    cluster_name = var.cluster_name
    subnet_ids = module.vpc.private_subnets_ids
}

module "vpc" {
  source = "git::github.com/JFMajer/terraform-aws-vpc-module?ref=v0.0.4"
  vpc_cidr = "10.0.0.0/16"
  public_subnets_count = 2
  private_subnets_count = 2
}

############################################|
# Create route53 alias record for the ALB   |
############################################|

resource "aws_route53_record" "alb_domain" {
  provider = aws.dns
  zone_id = "#{ROUTE53_ZONE_ID}#"
  name = var.subdomain
  type = "A"
  alias {
    name = module.webserver_cluster.load_balancer_dns
    zone_id = module.webserver_cluster.alb_zone_id
    evaluate_target_health = false
  }
}

############################################|
# Create SSL Certificate for the domain     |
############################################|

resource "aws_acm_certificate" "alb_cert" {
  domain_name = join(".", [var.subdomain, "heheszlo.com"])
  validation_method = "DNS"
}

############################################|
# Validate ACM Certificate                  |
############################################|

resource "aws_route53_record" "alb_cert_validation" {
  provider = aws.dns
  for_each = {
    for dvo in aws_acm_certificate.alb_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  type = each.value.type
  zone_id = "#{ROUTE53_ZONE_ID}#"
  name = each.value.name
  records = [each.value.record]
  ttl = 60
}

resource "aws_acm_certificate_validation" "alb_cert_validation" {
  certificate_arn = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_cert_validation : record.fqdn]
}

