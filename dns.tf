resource "aws_route53_record" "www-api-wedding-game-kaneel-net_record" {
  zone_id         = "Z058110827PJ0AX5ZBN9D"
  name            = "www.api.wedding-game.kaneel.net"
  type            = "CNAME"
  ttl             = 300
  records         = [aws_lb.the-wedding-game-api-lb.dns_name]
  allow_overwrite = true
}

resource "aws_route53_record" "api-wedding-game-kaneel-net_record" {
  zone_id         = "Z058110827PJ0AX5ZBN9D"
  name            = "api.wedding-game.kaneel.net"
  type            = "CNAME"
  ttl             = 300
  records         = [aws_lb.the-wedding-game-api-lb.dns_name]
  allow_overwrite = true
}

resource "aws_route53_record" "api-wedding-game-kaneel-net-cert-validation" {
  for_each = {
    for dvo in aws_acm_certificate.api-wedding-game-kaneel-net-cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = "Z058110827PJ0AX5ZBN9D"
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
}