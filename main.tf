terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.31.0"
    }
  }

  required_version = "1.2.8"
}

provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ubuntu" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  #associate_public_ip_address = true
  associate_public_ip_address = false
  monitoring                  = true

  tags = {
    Name = var.instance_name
  }

  key_name = "jtonello-tenable"
  
  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
    instance_metadata_tags = "enabled"
  }
}

resource "aws_ebs_snapshot" "example_snapshot" {
  volume_id = aws_instance.ubuntu.root_block_device.0.volume_id

  tags = {
    Name = "agentless-assessment_snap"
  }
}

