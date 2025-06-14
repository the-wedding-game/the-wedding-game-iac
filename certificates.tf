resource "aws_acm_certificate" "api-wedding-game-kaneel-net-cert" {
  domain_name               = "api.wedding-game.kaneel.net"
  validation_method         = "DNS"
  subject_alternative_names = ["www.api.wedding-game.kaneel.net"]

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-kaneel-net-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "api-wedding-game-kaneel-net-validated" {
  certificate_arn         = aws_acm_certificate.api-wedding-game-kaneel-net-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.api-wedding-game-kaneel-net-cert-validation : record.fqdn]
}
