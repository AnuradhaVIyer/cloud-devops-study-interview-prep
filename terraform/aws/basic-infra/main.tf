provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      project = "devops-portfolio"
      env     = "devops-lab"

    }
  }
}


resource "aws_vpc" "devops-lab-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.env_prefix}-${var.project_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "devops-lab-igw" {
  vpc_id = aws_vpc.devops-lab-vpc.id
  tags = {
    Name = "${var.env_prefix}-${var.project_prefix}-igw"
  }
}

resource "aws_route_table" "devops-lab-route-table" {
  vpc_id = aws_vpc.devops-lab-vpc.id
  tags = {
    Name = "${var.env_prefix}-${var.project_prefix}-route-table"
  }
}

resource "aws_subnet" "devops-lab-subnet-public" {
  vpc_id                  = aws_vpc.devops-lab-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env_prefix}-${var.project_prefix}-subnet-public"
  }
}

resource "aws_route" "devops-lab-route" {
  route_table_id         = aws_route_table.devops-lab-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.devops-lab-igw.id
}

resource "aws_security_group" "devops-lab-sg" {
  name        = "devops-lab-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.devops-lab-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "http"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env_prefix}-${var.project_prefix}-sg"
  }

}

resource "aws_instance" "devops-lab-web-server" {
  ami             = "ami-0c55b159cbfafe1f0"
  instance_type   = "t3.micro"
  subnet_id       = aws_subnet.devops-lab-subnet-public.id
  security_groups = [aws_security_group.devops-lab-sg.name]
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 8
  }
  tags = {
    Name = "${var.env_prefix}-${var.project_prefix}-web-server"
  }

}

