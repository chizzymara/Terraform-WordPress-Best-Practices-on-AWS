resource "aws_vpc" "wordpress" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "wordpress"
  }
}



#subnets

#public subnet in availability zone 1
resource "aws_subnet" "public-subnet-az1" {
  vpc_id                  = aws_vpc.wordpress.id
  cidr_block              = "10.0.200.0/24"
  availability_zone       = var.AvailabilityZone1
  map_public_ip_on_launch = true
  tags = {
    Name = "public subnet az1"
  }
}

#public subnet in availability zone 2
resource "aws_subnet" "public-subnet-az2" {
  vpc_id                  = aws_vpc.wordpress.id
  cidr_block              = "10.0.201.0/24"
  availability_zone       = var.AvailabilityZone2
  map_public_ip_on_launch = true
  tags = {
    Name = "public subnet az2"
  }
}

#subnet for the app in availability zone 1
resource "aws_subnet" "app-subnet-az1" {
  vpc_id            = aws_vpc.wordpress.id
  cidr_block        = "10.0.0.0/22"
  availability_zone = var.AvailabilityZone1

  tags = {
    Name = "app subnet az1"
  }
}

#subnet for the app in availability zone2
resource "aws_subnet" "app-subnet-az2" {
  vpc_id            = aws_vpc.wordpress.id
  cidr_block        = "10.0.4.0/22"
  availability_zone = var.AvailabilityZone2

  tags = {
    Name = "app subnet az2"
  }
}

#subnet for the data in availability zone1
resource "aws_subnet" "data-subnet-az1" {
  vpc_id            = aws_vpc.wordpress.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = var.AvailabilityZone1

  tags = {
    Name = "data subnet az1"
  }
}

#subnet for the data in availability zone2
resource "aws_subnet" "data-subnet-az2" {
  vpc_id            = aws_vpc.wordpress.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = var.AvailabilityZone2

  tags = {
    Name = "data subnet az2"
  }
}

#routing

#internet gateway

resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.wordpress.id

  tags = {
    Name = "wordpressInternetGateway"
  }
}

#elastic ip for association with nat gateway
resource "aws_eip" "eip-NAT1" {
  vpc        = true
  depends_on = [aws_internet_gateway.InternetGateway]
}

resource "aws_eip" "eip-NAT2" {
  vpc        = true
  depends_on = [aws_internet_gateway.InternetGateway]
}

#Network access control list
resource "aws_network_acl" "nacl" {
  vpc_id = aws_vpc.wordpress.id

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "wordpress"
  }
}

#Route table to associate with vpc
resource "aws_route_table" "wp_priv_route_table1" {
  vpc_id = aws_vpc.wordpress.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Nat-Az1.id
  }


  tags = {
    Name = "wordpress"
  }
}

#Route table to associate with vpc
resource "aws_route_table" "wp_priv_route_table2" {
  vpc_id = aws_vpc.wordpress.id


  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Nat-Az2.id
  }

  tags = {
    Name = "wordpress"
  }
}

resource "aws_route_table" "wp_pub_route_table" {
  vpc_id = aws_vpc.wordpress.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.InternetGateway.id
  }

  tags = {
    Name = "wordpress"
  }
}

#route table associations assigning the public route table to the two public subnets and assigning the private route tabe to the data and app subnets.
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-subnet-az1.id
  route_table_id = aws_route_table.wp_pub_route_table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public-subnet-az2.id
  route_table_id = aws_route_table.wp_pub_route_table.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.app-subnet-az1.id
  route_table_id = aws_route_table.wp_priv_route_table1.id
}

resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.app-subnet-az2.id
  route_table_id = aws_route_table.wp_priv_route_table2.id
}

resource "aws_route_table_association" "e" {
  subnet_id      = aws_subnet.data-subnet-az1.id
  route_table_id = aws_route_table.wp_priv_route_table1.id
}

resource "aws_route_table_association" "f" {
  subnet_id      = aws_subnet.data-subnet-az2.id
  route_table_id = aws_route_table.wp_priv_route_table2.id
}




#NAT gateway az1
resource "aws_nat_gateway" "Nat-Az1" {
  subnet_id     = aws_subnet.public-subnet-az1.id
  allocation_id = aws_eip.eip-NAT1.id
  tags = {
    Name = "Wordpress-Nat-Az1"
  }
  depends_on = [aws_internet_gateway.InternetGateway]
}


#NAT gateway az2
resource "aws_nat_gateway" "Nat-Az2" {
  subnet_id     = aws_subnet.public-subnet-az2.id
  allocation_id = aws_eip.eip-NAT2.id
  tags = {
    Name = "Wordpress-Nat-Az2"
  }
  depends_on = [aws_internet_gateway.InternetGateway]
}

