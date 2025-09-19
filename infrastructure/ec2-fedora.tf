terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "EC2 instance type for training"
  type        = string
  default     = "g4dn.xlarge"  # GPU instance for LLM training
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "fedora-llm-training"
}

# Data source for latest Fedora AMI
data "aws_ami" "fedora" {
  most_recent = true
  owners      = ["125523088429"]  # Fedora Project

  filter {
    name   = "name"
    values = ["Fedora-Cloud-Base-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group
resource "aws_security_group" "fedora_llm" {
  name_prefix = "${var.project_name}-"
  description = "Security group for Fedora LLM training instances"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6006
    to_port     = 6006
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
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

# EC2 Instance
resource "aws_instance" "fedora_llm_trainer" {
  ami           = data.aws_ami.fedora.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.fedora_llm.id]

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    project_name = var.project_name
  }))

  root_block_device {
    volume_type = "gp3"
    volume_size = 100
    encrypted   = true
  }

  tags = {
    Name    = "${var.project_name}-trainer"
    Project = var.project_name
    OS      = "Fedora"
  }
}

# Outputs
output "instance_id" {
  value = aws_instance.fedora_llm_trainer.id
}

output "public_ip" {
  value = aws_instance.fedora_llm_trainer.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/${var.key_name}.pem fedora@${aws_instance.fedora_llm_trainer.public_ip}"
}