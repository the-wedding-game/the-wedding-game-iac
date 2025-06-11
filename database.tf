resource "aws_db_instance" "the-wedding-game-db" {
  identifier        = "the-wedding-game-db2"
  instance_class    = "db.t4g.micro"
  engine            = "postgres"
  engine_version    = "17.2"
  allocated_storage = 10
  apply_immediately = true
  username          = var.db_user
  password          = var.db_pass
  # db_name                   = var.db_name
  vpc_security_group_ids    = [aws_security_group.connect_to_postgres.id]
  db_subnet_group_name      = aws_db_subnet_group.the-wedding-game-db-subnet-group.name
  parameter_group_name      = aws_db_parameter_group.the-wedding-game-db-parameter-group.name
  publicly_accessible       = true
  final_snapshot_identifier = "${terraform.workspace}-the-wedding-game-db2-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  snapshot_identifier       = data.aws_db_snapshot.latest_snapshot.id

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-database"
  }
}

data "aws_db_snapshot" "latest_snapshot" {
  db_instance_identifier = "the-wedding-game-db2"
  most_recent            = true
}

resource "aws_security_group" "connect_to_postgres" {
  name        = "connect_to_postgres"
  description = "Allow connections to Postgres database"
  vpc_id      = aws_vpc.the-wedding-game-vpc.id

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-sg-postgres"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_on_5432" {
  security_group_id = aws_security_group.connect_to_postgres.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-sg-ingress-rule"
  }
}

resource "aws_db_subnet_group" "the-wedding-game-db-subnet-group" {
  subnet_ids = [aws_subnet.the-wedding-game-public-subnet_1.id, aws_subnet.the-wedding-game-public-subnet_2.id]

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-db-subnet-group"
  }
}

resource "aws_db_parameter_group" "the-wedding-game-db-parameter-group" {
  family      = "postgres17"
  description = "Custom parameter group for the-wedding-game database"
  parameter {
    name  = "rds.force_ssl"
    value = 0
  }

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-db-parameter-group"
  }
}
