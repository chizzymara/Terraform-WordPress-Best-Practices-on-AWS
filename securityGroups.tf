resource "aws_security_group" "bastion-guest" {
  name        = "allow-ssh-bastion"
  description = "for the bastion guest in this case the wordpress instance to Allows inbound traffic only from the bastion host"
  vpc_id      = aws_vpc.wordpress.id

  ingress {
    description      = "allowing ssh from the ip address of the bastion host"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description     = "allowing ssh from the ip address of the bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion-host.id]
  }
  ingress {
    description     = "allowing ssh from the ip address of the bastion host"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-ssh-bastion"
  }
}



resource "aws_security_group" "bastion-host" {
  name        = "SG-bastion-Host"
  description = "for the bastion host, to be used on the ec instance which will serve as the bastion host"
  vpc_id      = aws_vpc.wordpress.id

  ingress {
    description      = "security group for bastion host"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SG-bastion-Host"
  }
}


resource "aws_security_group" "lb_sg" {
  name        = "SG-wordpress-lb-sg"
  description = "for the application load balancer"
  vpc_id      = aws_vpc.wordpress.id

  ingress {
    description      = "security group for bastion host"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "efs" {
  name        = "efs-sg"
  description = "Allows inbound efs traffic from ec2"
  vpc_id      = aws_vpc.wordpress.id

  ingress {
    security_groups = [aws_security_group.bastion-guest.id]
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
  }

  egress {
    security_groups = [aws_security_group.bastion-guest.id]
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
  }
}