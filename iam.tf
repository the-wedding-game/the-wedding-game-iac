resource "aws_iam_role" "the-wedding-game-role-ecs-task-execute" {
  name = "the-wedding-game-role-ecs-task-execute"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-role-ecs-task-execution"
  }
}

resource "aws_iam_role_policy_attachment" "ec2-read-only-policy-attachment" {
  role       = aws_iam_role.the-wedding-game-role-ecs-task-execute.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "the-wedding-game-role-ecs-task-role" {
  name = "the-wedding-game-role-ecs-task-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-role-ecs-task-role"
  }
}

resource "aws_iam_role_policy" "the-wedding-game-api-policy" {
  name   = "the-wedding-game-api-policy"
  policy = file("task-role-policy.json")
  role   = aws_iam_role.the-wedding-game-role-ecs-task-role.name
}

resource "aws_s3_bucket_policy" "the-wedding-game-api-elb-s3-bucket-access" {
  bucket = "the-wedding-game"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::156460612806:root"
        },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::the-wedding-game/load-balancer-logs/AWSLogs/996835183634/*",
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:elasticloadbalancing:eu-west-1:996835183634:loadbalancer/*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "the-wedding-game-rds-monitoring-role" {
  name = "the-wedding-game-rds-monitoring-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "monitoring.rds.amazonaws.com"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "StringLike" : {
            "aws:SourceArn" : "arn:aws:rds:eu-west-1:996835183634:db:the-wedding-game-db2"
          },
          "StringEquals" : {
            "aws:SourceAccount" : "996835183634"
          }
        }
      }
    ]
  })

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-rds-monitoring-role"
  }
}

resource "aws_iam_role_policy_attachment" "the-wedding-game-rds-enhanced-monitoring" {
  role       = aws_iam_role.the-wedding-game-rds-monitoring-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
