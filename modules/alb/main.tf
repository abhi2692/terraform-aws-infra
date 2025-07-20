resource aws_security_group alb_sg {
  name        = "${var.project}-${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "myalb" {
    name               = "${var.project}-${var.environment}-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb_sg.id]
    subnets            = var.public_subnet_ids
    
    enable_deletion_protection = false
    
    tags = {
        Name        = "${var.project}-${var.environment}-alb"
        Environment = var.environment
        Project     = var.project
    }
}

resource "aws_alb_target_group" "mytg" {
  name     = "${var.project}-${var.environment}-tg"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project}-${var.environment}-tg"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_alb_listener" "myalblistener" {
  load_balancer_arn = aws_alb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.mytg.arn
  }

  tags = {
    Name        = "${var.project}-${var.environment}-listener"
    Environment = var.environment
    Project     = var.project
  }
  
}

