resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.financecorp.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "FinanceCorp-v2-Public-A"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.financecorp.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "FinanceCorp-v2-Public-B"
  }
}

# Private application subnets
resource "aws_subnet" "app_a" {
  vpc_id            = aws_vpc.financecorp.id
  cidr_block        = "10.20.11.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "FinanceCorp-v2-App-Private-A"
  }
}

resource "aws_subnet" "app_b" {
  vpc_id            = aws_vpc.financecorp.id
  cidr_block        = "10.20.12.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "FinanceCorp-v2-App-Private-B"
  }
}

# Private database subnets
resource "aws_subnet" "db_a" {
  vpc_id            = aws_vpc.financecorp.id
  cidr_block        = "10.20.21.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "FinanceCorp-v2-DB-Private-A"
  }
}

resource "aws_subnet" "db_b" {
  vpc_id            = aws_vpc.financecorp.id
  cidr_block        = "10.20.22.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "FinanceCorp-v2-DB-Private-B"
  }
}