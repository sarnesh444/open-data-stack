provider "aws" {
  region = var.aws_region
}

# --- IAM Role for EC2 ---
resource "aws_iam_role" "trino_ec2_role" {
  name = "trino_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.trino_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "glue_access" {
  role       = aws_iam_role.trino_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}

resource "aws_iam_instance_profile" "trino_profile" {
  name = "trino_ec2_profile"
  role = aws_iam_role.trino_ec2_role.name
}

# --- Security Group ---
resource "aws_security_group" "trino_sg" {
  name        = "trino_sg"
  description = "Allow SSH, Trino, and Superset"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: Restrict this to your IP in production
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8088
    to_port     = 8088
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

# --- EC2 Instance ---
resource "aws_instance" "trino_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile   = aws_iam_instance_profile.trino_profile.name
  vpc_security_group_ids = [aws_security_group.trino_sg.id]

  user_data = templatefile("user_data.sh", {
    repo_url   = var.repo_url
    aws_region = var.aws_region
  })

  tags = {
    Name = "Trino-Data-Stack"
  }
}
