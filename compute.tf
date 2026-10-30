# Keep EC2 instances disabled until testing
variable "enable_compute" {
  description = "Deploy FinanceCorp EC2 application servers"
  type        = bool
  default     = false
}

# Amazon Linux 2023 AMI from AWS Systems Manager
data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Private EC2 application servers
resource "aws_instance" "app" {
  for_each = var.enable_compute ? {
    app_01 = {
      subnet_id = aws_subnet.app_a.id
      name      = "FinanceCorp-v2-App-01"
    }
    app_02 = {
      subnet_id = aws_subnet.app_b.id
      name      = "FinanceCorp-v2-App-02"
    }
  } : {}

  ami                    = data.aws_ssm_parameter.amazon_linux.value
  instance_type          = "t3.micro"
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  user_data = templatefile("${path.module}/scripts/bootstrap.sh", {
    app_bucket  = aws_s3_bucket.application.id
    server_name = each.value.name
  })

  depends_on = [
    aws_s3_object.app_py,
    aws_s3_object.requirements,
    aws_s3_object.python_wheels,
    aws_iam_role_policy.app_s3_read,
    aws_vpc_endpoint.s3
  ]

  associate_public_ip_address = false

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name    = each.value.name
    Project = "FinanceCorp-v2"
    Role    = "FinanceCorp-App"
  }
}