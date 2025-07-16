resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project}-${var.environment}-${var.component}-sg"
  description = "Allow SSH and app access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

resource "aws_eip" "ec2_eip" {
  instance = aws_instance.ec2_instance.id
  tags = {
    Name = "${var.project}-${var.environment}-${var.component}-eip"
  }
}


resource "aws_instance" "ec2_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = aws_key_pair.ec2_key.key_name
  associate_public_ip_address = true
  user_data                   = var.user_data

  tags = {
    Name = "${var.project}-${var.environment}-${var.component}-ec2"
  }
}
