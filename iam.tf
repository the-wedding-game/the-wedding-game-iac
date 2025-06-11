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
