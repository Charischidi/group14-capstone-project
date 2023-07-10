# # Retrieve LoadBalancer and Route53 Hosted Zone ID and Create "A" records

# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.0"
#     }
#   }
# }

# data "aws_lb_hosted_zone_id" "alb-hosted-zone" {}

# data "aws_route53_zone" "route53" {
#    name         = "chichieo.live"

# }

# data "kubernetes_service" "alb-service" {
#   metadata {
#     name = "fleetman-webapp"
#   }
# }

# resource "aws_route53_record" "www" {
#   zone_id = data.aws_route53_zone.route53.name
#   name    = "www.${data.aws_route53_zone.route53.name}"
#   type    = "A"

#   alias {
#     name                   = data.kubernetes_service.alb-service.status.0.load_balancer.0.ingress.0.hostname
#     zone_id                = data.aws_lb_hosted_zone_id.alb-hosted-zone.id
#     evaluate_target_health = true
#   }
# }

