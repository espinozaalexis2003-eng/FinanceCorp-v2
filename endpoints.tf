variable "enable_private_endpoints" {
  description = "Enable paid SSM interface endpoints for EC2 testing"
  type        = bool
  default     = false
}

# Security group for VPC interface endpoints
resource "aws_security_group" "endpoints" {
  name        = "FinanceCorp-v2-Endpoints-SG"
  description = "Private AWS service endpoint access"
  vpc_id      = aws_vpc.financecorp.id

  tags = {
    Name = "FinanceCorp-v2-Endpoints-SG"
  }
}

# Allow private EC2 servers to connect to endpoints over HTTPS
resource "aws_vpc_security_group_ingress_rule" "endpoint_https" {
  security_group_id            = aws_security_group.endpoints.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

# Systems Manager interface endpoints
resource "aws_vpc_endpoint" "ssm" {
  for_each = var.enable_private_endpoints ? toset([
    "ssm",
    "ssmmessages",
    "ec2messages"
  ]) : toset([])

  vpc_id              = aws_vpc.financecorp.id
  service_name        = "com.amazonaws.us-east-2.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.app_a.id, aws_subnet.app_b.id]
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "FinanceCorp-v2-${each.key}-Endpoint"
  }
}

# S3 Gateway endpoint: no hourly endpoint charge
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.financecorp.id
  service_name      = "com.amazonaws.us-east-2.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.app_a.id,
    aws_route_table.app_b.id
  ]

  tags = {
    Name = "FinanceCorp-v2-S3-Gateway-Endpoint"
  }
}