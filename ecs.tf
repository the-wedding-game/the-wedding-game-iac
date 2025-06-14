resource "aws_ecs_cluster" "the-wedding-game-ecs-cluster" {
  name = "the-wedding-game-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-ecs-cluster"
  }
}

resource "aws_ecs_service" "the-wedding-game-ecs-service-api" {
  name                    = "the-wedding-game-ecs-service-api"
  cluster                 = aws_ecs_cluster.the-wedding-game-ecs-cluster.id
  task_definition         = aws_ecs_task_definition.the-wedding-game-api-task-definition.id
  desired_count           = 1
  launch_type             = "FARGATE"
  enable_ecs_managed_tags = true
  network_configuration {
    subnets          = [aws_subnet.the-wedding-game-private-subnet_1.id]
    security_groups  = [aws_security_group.the-wedding-group-api-sg.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.the-wedding-game-api-ecs-target-group.arn
    container_name   = "the-wedding-game-api"
    container_port   = 8080
  }
  depends_on = [aws_db_instance.the-wedding-game-db, aws_lb.the-wedding-game-api-lb]

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-ecs-service-api"
  }
}

resource "aws_security_group" "the-wedding-group-api-sg" {
  name        = "the-wedding-group-api-sg"
  description = "Accepts connections on 8080. Allows on 443."
  vpc_id      = aws_vpc.the-wedding-game-vpc.id

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-sg-8080"
  }
}

resource "aws_vpc_security_group_ingress_rule" "accept-on-8080" {
  description                  = "Allow incoming connections on port 8080 from the ELB"
  security_group_id            = aws_security_group.the-wedding-group-api-sg.id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
  referenced_security_group_id = aws_security_group.the-wedding-game-api-elb-sg.id

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-sg-ingress-rule"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_on_443" {
  description       = "Allow outgoing connections on 443 to anywhere"
  security_group_id = aws_security_group.the-wedding-group-api-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-sg-egress-rule-443"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_on_5432" {
  description       = "Allow outgoing connections on 5432 from anywhere"
  security_group_id = aws_security_group.the-wedding-group-api-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-sg-egress-rule-5432"
  }
}
