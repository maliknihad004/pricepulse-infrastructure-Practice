terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

# Find the latest Ubuntu 24.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "pricepulse" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "pricepulse-vpc"
  }
}

resource "aws_internet_gateway" "pricepulse" {
  vpc_id = aws_vpc.pricepulse.id

  tags = {
    Name = "pricepulse-igw"
  }
}

resource "aws_subnet" "pricepulse_public" {
  vpc_id                  = aws_vpc.pricepulse.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "pricepulse-public-subnet"
  }
}

resource "aws_route_table" "pricepulse_public" {
  vpc_id = aws_vpc.pricepulse.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pricepulse.id
  }

  tags = {
    Name = "pricepulse-public-rt"
  }
}

resource "aws_route_table_association" "pricepulse_public" {
  subnet_id      = aws_subnet.pricepulse_public.id
  route_table_id = aws_route_table.pricepulse_public.id
}

resource "aws_security_group" "pricepulse" {
  name        = "pricepulse-sg"
  description = "Security group for PricePulse EC2"
  vpc_id      = aws_vpc.pricepulse.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "pricepulse-sg"
  }
}

resource "aws_instance" "pricepulse" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.pricepulse.key_name

  subnet_id = aws_subnet.pricepulse_public.id

  vpc_security_group_ids = [
    aws_security_group.pricepulse.id
  ]

  associate_public_ip_address = true

  tags = {
    Name = "pricepulse-server"
  }
}

resource "aws_key_pair" "pricepulse" {
  key_name   = "pricepulse-key"
  public_key = var.ssh_public_key

  tags = {
    Name = "pricepulse-key"
  }
}