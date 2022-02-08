data "aws_route53_zone" "selected" {
  name = var.dnsName
}

resource "aws_route53_record" "a-record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.dnsName
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.worpress-cloud-front.domain_name
    zone_id                = aws_cloudfront_distribution.worpress-cloud-front.hosted_zone_id
    evaluate_target_health = true
  }
}