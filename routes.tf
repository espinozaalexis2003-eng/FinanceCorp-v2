
# Internet Gateway
resource "aws_internet_gateway" "financecorp" {
  vpc_id = aws_vpc.financecorp.id

  tags = {
    Name = "FinanceCorp-v2-IGW"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.financecorp.id

  tags = {
    Name = "FinanceCorp-v2-Public-RT"
  }
}

# Route internet traffic through the IGW
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.financecorp.id
}

# Connect Public A to the public route table
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Connect Public B to the public route table
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Private Application Route Table A
resource "aws_route_table" "app_a" {
  vpc_id = aws_vpc.financecorp.id

  tags = {
    Name = "FinanceCorp-v2-App-Private-RT-A"
  }
}

resource "aws_route_table_association" "app_a" {
  subnet_id      = aws_subnet.app_a.id
  route_table_id = aws_route_table.app_a.id
}

# Private Application Route Table B
resource "aws_route_table" "app_b" {
  vpc_id = aws_vpc.financecorp.id

  tags = {
    Name = "FinanceCorp-v2-App-Private-RT-B"
  }
}

resource "aws_route_table_association" "app_b" {
  subnet_id      = aws_subnet.app_b.id
  route_table_id = aws_route_table.app_b.id
}

# Private Database Route Table A
resource "aws_route_table" "db_a" {
  vpc_id = aws_vpc.financecorp.id

  tags = {
    Name = "FinanceCorp-v2-DB-Private-RT-A"
  }
}

resource "aws_route_table_association" "db_a" {
  subnet_id      = aws_subnet.db_a.id
  route_table_id = aws_route_table.db_a.id
}

# Private Database Route Table B
resource "aws_route_table" "db_b" {
  vpc_id = aws_vpc.financecorp.id

  tags = {
    Name = "FinanceCorp-v2-DB-Private-RT-B"
  }
}

resource "aws_route_table_association" "db_b" {
  subnet_id      = aws_subnet.db_b.id
  route_table_id = aws_route_table.db_b.id
}