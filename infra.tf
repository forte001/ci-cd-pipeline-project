terraform {
backend "remote" {
         # The name of your Terraform Cloud organization.
         organization = "Forte001"

         # The name of the Terraform Cloud workspace to store Terraform state files in.
         workspaces {
           name = "ci-cd-pipeline"
        }
       }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

# This module that creates the VPC

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "terraform-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# Creates the security group and its rules

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow http, https, and ssh inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
   cidr_blocks       = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
   cidr_blocks       = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description      = "HTTPS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "web_sg"
  }

}
# This module creates the EC2 instance

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["1", "2"])

  name = "test-server-${each.key}"

  ami                    = "ami-0a606d8395a538502"
  instance_type          = "t2.micro"
  key_name               = "test-server"
  user_data              = "${file("deployv2.sh")}"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  subnet_id              = "${module.vpc.public_subnets[0]}"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# This outputs the public ip of the EC2 instance

output "ec2_global_ips" {
  description = " The Public IPs of the Ec2 instances created "
  value = ["${module.ec2_instance.*.public_ip}"]
}