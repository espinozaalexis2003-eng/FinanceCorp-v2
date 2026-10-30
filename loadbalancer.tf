
# Control whether the ALB is deployed
variable "enable_load_balancer" {
  description = "Deploy FinanceCorp Application Load Balancer"
  type        = bool
  default     = false
}

# Application Load Balancer
resource "aws_lb" "financecorp" {
  count = var.enable_load_balancer ? 1 : 0

  name               = "financecorp-v2-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  enable_deletion_protection = false

  tags = {
    Name    = "FinanceCorp-v2-ALB"
    Project = "FinanceCorp-v2"
  }
}

# Target Group
resource "aws_lb_target_group" "app" {
  count = var.enable_load_balancer ? 1 : 0

  name        = "financecorp-v2-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.financecorp.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Name = "FinanceCorp-v2-App-TG"
  }
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  count = var.enable_load_balancer ? 1 : 0

  load_balancer_arn = aws_lb.financecorp[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app[0].arn
  }
}

# Attach EC2 instances to target group
resource "aws_lb_target_group_attachment" "app" {
  for_each = var.enable_load_balancer && var.enable_compute ? aws_instance.app : {}

  target_group_arn = aws_lb_target_group.app[0].arn
  target_id        = each.value.id
  port             = 80
}
