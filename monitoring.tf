resource "aws_vpc" "monitoring" {
  cidr_block = local.vpc_cidr

  tags = {
    "Name" = "monitoring"
  }
}

resource "aws_subnet" "monitoring" {
  vpc_id     = aws_vpc.monitoring.id
  cidr_block = local.vm_cidr

  tags = {
    "Name" = "monitoring"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.monitoring.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.monitoring.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_security_group" "monitoring" {
  vpc_id = aws_vpc.monitoring.id
  name   = "monitoring"

  ingress {
    from_port   = local.ssh_port
    to_port     = local.ssh_port
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

resource "aws_instance" "monitoring" {
  ami                         = data.aws_ami.this.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.monitoring.id
  user_data                   = templatefile("./user_data.tpl", { pub_key = var.pub_key })
  vpc_security_group_ids      = [aws_security_group.monitoring.id]

  tags = {
    "Name" = "monitoring"
  }
}

