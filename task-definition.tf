resource "aws_ecs_task_definition" "the-wedding-game-api-task-definition" {
  family = "the-wedding-game-api-task-definition-family"
  container_definitions = jsonencode([
    {
      name  = "the-wedding-game-api"
      image = "registry.hub.docker.com/kaneeldias/the-wedding-game-api:${var.image_hash}"
      cpu   = 0
      portMappings = [
        {
          name          = "the-wedding-game-api-8080-tcp"
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/the-wedding-game-api"
          "awslogs-region"        = "eu-west-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        {
          name  = "AWS_FOLDER_NAME",
          value = "testing-folder"
        },
        {
          name  = "AWS_REGION",
          value = "eu-west-1"
        },
        {
          name  = "ADMIN_PASSWORD",
          value = "abcd@123"
        },
        {
          name  = "AWS_BUCKET_NAME",
          value = "the-wedding-game"
        },
        {
          name  = "DB_PASS",
          value = var.db_pass
        },
        {
          name  = "DB_PORT",
          value = "5432"
        },
        {
          name  = "GIN_MODE",
          value = "release"
        },
        {
          name  = "DB_USER",
          value = var.db_user
        },
        {
          name  = "DB_NAME",
          value = var.db_name
        },
        {
          name  = "ENV",
          value = "production"
        },
        {
          name  = "DB_HOST",
          value = aws_db_instance.the-wedding-game-db.address
        },
        {
          name  = "AWS_BUCKET_ENDPOINT",
          value = "https://s3.eu-west-1.amazonaws.com"
        }
      ]
    }
  ])
  memory                   = "3072"
  cpu                      = "1024"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.the-wedding-game-role-ecs-task-execute.arn
  task_role_arn            = aws_iam_role.the-wedding-game-role-ecs-task-role.arn

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-ecs-task-definition-api"
  }
}
