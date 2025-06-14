resource "aws_vpc" "the-wedding-game-vpc" {
  #checkov:skip=CKV2_AWS_11: TODO: enable flow logs
  #checkov:skip=CKV2_AWS_12: Default security group blocks all traffic
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-vpc"
  }
}

resource "aws_default_security_group" "the-wedding-game-default-sg" {
  vpc_id = aws_vpc.the-wedding-game-vpc.id

  ingress {
    protocol  = "-1"
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-default-sg"
  }
}

resource "aws_subnet" "the-wedding-game-public-subnet_1" {
  vpc_id                  = aws_vpc.the-wedding-game-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-1a"

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-subnet"
  }
}

resource "aws_subnet" "the-wedding-game-public-subnet_2" {
  vpc_id                  = aws_vpc.the-wedding-game-vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-1b"

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-subnet"
  }
}

resource "aws_internet_gateway" "the-wedding-game-igw" {
  vpc_id = aws_vpc.the-wedding-game-vpc.id

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-igw"
  }
}

resource "aws_route_table" "the-wedding-game-rt" {
  vpc_id = aws_vpc.the-wedding-game-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.the-wedding-game-igw.id
  }

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-rt"
  }
}

resource "aws_route_table_association" "the-wedding-game-rta_1" {
  subnet_id      = aws_subnet.the-wedding-game-public-subnet_1.id
  route_table_id = aws_route_table.the-wedding-game-rt.id
}

resource "aws_route_table_association" "the-wedding-game-rta_2" {
  subnet_id      = aws_subnet.the-wedding-game-public-subnet_2.id
  route_table_id = aws_route_table.the-wedding-game-rt.id
}

resource "aws_subnet" "the-wedding-game-private-subnet_1" {
  vpc_id                  = aws_vpc.the-wedding-game-vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-1a"

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-subnet"
  }
}

resource "aws_route_table" "the-wedding-game-private-rt" {
  vpc_id = aws_vpc.the-wedding-game-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.the-wedding-game-nat-gw-1.id
  }

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-rt"
  }
}

resource "aws_route_table_association" "the-wedding-game-private-rta_1" {
  subnet_id      = aws_subnet.the-wedding-game-private-subnet_1.id
  route_table_id = aws_route_table.the-wedding-game-private-rt.id
}

resource "aws_eip" "the-wedding-game-nat-eip" {
  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-nat-eip"
  }
}

resource "aws_nat_gateway" "the-wedding-game-nat-gw-1" {
  allocation_id = aws_eip.the-wedding-game-nat-eip.id
  subnet_id     = aws_subnet.the-wedding-game-public-subnet_1.id

  tags = {
    Project = "the-wedding-game"
    Name    = "the-wedding-game-nat-gw"
  }
}