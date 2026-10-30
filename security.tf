
# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "FinanceCorp-v2-ALB-SG"
  description = "Security group for public ALB"
  vpc_id      = aws_vpc.financecorp.id

  tags = {
    Name = "FinanceCorp-v2-ALB-SG"
  }
}

# Allow HTTP from the internet
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# ALB outbound HTTP to application servers
resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# Application Security Group
resource "aws_security_group" "app" {
  name        = "FinanceCorp-v2-App-SG"
  description = "Security group for private application servers"
  vpc_id      = aws_vpc.financecorp.id

  tags = {
    Name = "FinanceCorp-v2-App-SG"
  }
}

# Allow HTTP only from the ALB
resource "aws_vpc_security_group_ingress_rule" "app_http" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

# App outbound HTTPS for AWS service endpoints
resource "aws_vpc_security_group_egress_rule" "app_https" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# App outbound PostgreSQL to database
resource "aws_vpc_security_group_egress_rule" "app_postgres" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.db.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

# Database Security Group
resource "aws_security_group" "db" {
  name        = "FinanceCorp-v2-DB-SG"
  description = "PostgreSQL database security group"
  vpc_id      = aws_vpc.financecorp.id

  tags = {
    Name = "FinanceCorp-v2-DB-SG"
  }
}

# Allow PostgreSQL only from App SG
resource "aws_vpc_security_group_ingress_rule" "db_postgres" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}