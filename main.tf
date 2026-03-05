terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {  # Optional for state
    bucket = "your-tf-state-bucket"
    key    = "ec2/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "ec2_sg" {
  name_prefix = "ec2-jenkins-sg"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

resource "aws_key_pair" "deployer" {
  key_name   = "jenkins-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Generate SSH key locally
}

resource "aws_instance" "web" {
  ami                    = "ami-0abcdef1234567890"  # Latest Amazon Linux 2
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  tags = {
    Name = "Jenkins-Terraform-EC2"
  }
}
