resource "aws_route53_zone" "primary" {
  name = "dryrun.tk"
}

data "aws_lb" "traefik_lb" {
  name = "aa86ec326ed054e3199dca23e0c503e5"
}



resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "argocd.dryrun.tk"
  type    = "A"

  alias {
    name                   = data.aws_lb.traefik_lb.dns_name #aws_elb.main.dns_name
    zone_id                = data.aws_lb.traefik_lb.zone_id #aws_elb.main.zone_id
    evaluate_target_health = true
  }
}
