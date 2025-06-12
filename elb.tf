resource "aws_lb" "the-wedding-game-api-lb" {
  #checkov:skip=CKV_AWS_150: Need to be able to easily delete this dev load balancer
  name                       = "the-wedding-game-api-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.the-wedding-game-api-elb-sg.id]
  subnets                    = [aws_subnet.the-wedding-game-public-subnet_1.id, aws_subnet.the-wedding-game-public-subnet_2.id]
  drop_invalid_header_fields = true
  access_logs {
    bucket  = "the-wedding-game"
    prefix  = "load-balancer-logs"
    enabled = true
  }

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-api-lb"
  }
}

resource "aws_lb_target_group" "the-wedding-game-api-ecs-target-group" {
  name        = "the-wedding-game-tg"
  port        = 8080
  protocol    = "HTTPS"
  target_type = "ip"
  vpc_id      = aws_vpc.the-wedding-game-vpc.id

  health_check {
    path = "/"
  }

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-api-elb-tg"
  }
}

resource "aws_lb_listener" "the-wedding-game-api-lb-listener-80" {
  load_balancer_arn = aws_lb.the-wedding-game-api-lb.arn
  port              = 80
  protocol          = "HTTP"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-api-elb-listener-80"
  }
}

resource "aws_lb_listener" "the-wedding-game-api-lb-listener-443" {
  load_balancer_arn = aws_lb.the-wedding-game-api-lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.api-wedding-game-kaneel-net-cert.arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.the-wedding-game-api-ecs-target-group.arn
  }

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-api-elb-listener-443"
  }

  depends_on = [aws_acm_certificate_validation.api-wedding-game-kaneel-net-validated]
}

resource "aws_security_group" "the-wedding-game-api-elb-sg" {
  name        = "the-wedding-game-api-elb-sg"
  description = "Allow connections on HTTP and HTTPS"
  vpc_id      = aws_vpc.the-wedding-game-vpc.id

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-api-elb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "accept_on_443" {
  description       = "Accept incoming connections on port 443 from anywhere"
  security_group_id = aws_security_group.the-wedding-game-api-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-api-elb-sg-ingress-rule-443"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_on_8080" {
  description       = "Allow outgoing connections on port 8080 from anywhere"
  security_group_id = aws_security_group.the-wedding-game-api-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-api-elb-sg-ingress-rule-8080"
  }
}

resource "aws_wafregional_web_acl" "the-wedding-game-lb-waf-acl" {
  #checkov:skip=CKV_AWS_176: TODO: enable logging
  #checkov:skip=CKV_AWS_175: I don't have any rules to add at the moment
  name        = "the-wedding-game-lb-waf-acl"
  metric_name = "the_wedding_game_lb_waf_acl"
  default_action {
    type = "ALLOW"
  }

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-lb-waf-acl"
  }
}

resource "aws_wafregional_web_acl_association" "the-wedding-game-lb-waf-assoc" {
  resource_arn = aws_lb.the-wedding-game-api-lb.arn
  web_acl_id   = aws_wafregional_web_acl.the-wedding-game-lb-waf-acl.id
}
