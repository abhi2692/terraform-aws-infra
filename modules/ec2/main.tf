resource "aws_eip" "ec2_eip" {
  instance = aws_instance.app.id
  tags = {
    Name = "${var.project}-${var.environment}-${var.component}-eip"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project}-${var.environment}-${var.component}-sg"
  description = "Allow SSH and app access"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.environment}-${var.component}-sg"
  }
}

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  key_name                    = var.key_name
  user_data                   = var.user_data
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = var.iam_instance_profile

  tags = {
    Name        = "${var.environment}-${var.component}-${var.project}"
    Environment = var.environment
    Component   = var.component
    Project     = var.project
  }
}
