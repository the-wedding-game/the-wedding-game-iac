resource "aws_lb" "the-wedding-game-api-lb" {
  name               = "the-wedding-game-api-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.the-wedding-game-api-elb-sg.id]
  subnets            = [aws_subnet.the-wedding-game-public-subnet_1.id, aws_subnet.the-wedding-game-public-subnet_2.id]

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-api-lb"
  }
}

resource "aws_lb_target_group" "the-wedding-game-api-ecs-target-group" {
  name        = "ecs-target-group"
  port        = 8080
  protocol    = "HTTP"
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

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.the-wedding-game-api-ecs-target-group.arn
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

resource "aws_vpc_security_group_ingress_rule" "accept_on_80" {
  security_group_id = aws_security_group.the-wedding-game-api-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-api-elb-sg-ingress-rule-80"
  }
}

resource "aws_vpc_security_group_ingress_rule" "accept_on_443" {
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
  security_group_id = aws_security_group.the-wedding-game-api-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-api-elb-sg-ingress-rule-443"
  }
}
