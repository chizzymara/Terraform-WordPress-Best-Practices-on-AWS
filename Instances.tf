#ami for the instances, first version we will work with ubuntu 
#but we can include conditionals for other ami's in subsequent versions
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

  owners = ["099720109477"] # Canonical. you can find this by copying the ami id of the os you want to use and search witht that id in the ami section of the a`ws console. owners are the same per os
}

#keypair to enable us ssh to our instances
data "aws_key_pair" "key_pair" {
  key_name = var.Key_pair_name

  tags = {
    Name = "wordpress"
  }
}

#bastionhost to ssh into the private wordpress instances
resource "aws_instance" "Bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public-subnet-az1.id
  vpc_security_group_ids = [aws_security_group.bastion-host.id]
  depends_on             = [data.aws_key_pair.key_pair]
  key_name               = data.aws_key_pair.key_pair.key_name
  tags = {
    Name = "Bastion"
  }
}

