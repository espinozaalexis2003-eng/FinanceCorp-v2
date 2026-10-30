resource "aws_vpc" "financecorp" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "FinanceCorp-v2-VPC"
    Project = "FinanceCorp-v2"
  }
}