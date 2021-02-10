# network 
#
resource "aws_vpc" "target" {
  count = local.target_count

  cidr_block = local.vpc_cidr

  tags = {
    "Name" = "target-${count.index}"
  }
}

resource "aws_subnet" "target" {
  count = local.target_count

  vpc_id            = aws_vpc.target[count.index].id
  cidr_block        = local.vm_cidr
  availability_zone = local.other_azs[count.index]

  tags = {
    "Name" = "target-${count.index}"
  }
}


# instance
resource "aws_security_group" "target" {
  count = local.target_count

  name   = "target-${count.index}"
  vpc_id = aws_vpc.target[count.index].id

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


resource "aws_instance" "target" {
  count = local.target_count

  ami                    = data.aws_ami.this.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.target[count.index].id
  user_data              = templatefile("./user_data.tpl", { pub_key = var.pub_key })
  vpc_security_group_ids = [aws_security_group.target[count.index].id]

  tags = {
    "Name" = "target-${count.index}"
  }
}
