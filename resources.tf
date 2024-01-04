#Необходимо создать и сконфигурировать следующие сервисы:
#VPC 
resource "aws_vpc" "vpc1" {
  tags = {
    Name = "vpc1"
  }
  cidr_block = "10.0.1.0/24"
}

resource "aws_vpc" "vpc2" {
  tags = {
    Name = "vpc2"
  }
  cidr_block = "10.0.2.0/24"
}

resource "aws_vpc" "vpc3" {
  tags = {
    Name = "vpc3"
  }
  cidr_block = "10.0.3.0/24"
}

#Subnets
resource "aws_subnet" "subnet1" {
  tags = {
    Name = "subnet1"
  }
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/26"
  availability_zone = "eu-west-3a"
}
 
resource "aws_subnet" "subnet2" {
  tags = {
    Name = "subnet2"
  }
  vpc_id     = aws_vpc.vpc2.id
  cidr_block = "10.0.2.0/26"
  availability_zone = "eu-west-3b"
}

resource "aws_subnet" "subnet3" {
  tags = {
    Name = "subnet3"
  }
  vpc_id     = aws_vpc.vpc3.id
  cidr_block = "10.0.3.0/26"
  availability_zone = "eu-west-3c"
}

#Gateways
#resource "aws_internet_gateway" "gw1" {
#  vpc_id = aws_vpc.vpc1.id
#}

#resource "aws_internet_gateway" "gw2" {
#  vpc_id = aws_vpc.vpc2.id
#}

resource "aws_internet_gateway" "gw3" {
  tags = {
    Name = "gw3"
  }
  vpc_id = aws_vpc.vpc3.id
}

#VPC peering
resource "aws_vpc_peering_connection" "peering_vpc3_vpc1" {
  tags = {
    Name = "peering_vpc3_vpc1"
  }
  vpc_id      = aws_vpc.vpc3.id
  peer_vpc_id = aws_vpc.vpc1.id
  auto_accept = true
}

resource "aws_vpc_peering_connection" "peering_vpc3_vpc2" {
  tags = {
    Name = "peering_vpc3_vpc2"
  }
  vpc_id      = aws_vpc.vpc3.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = true
}

#Routing tables
#Настроить сетевое взаимодейтсвие таким образом, чтобы сетевые пакеты из VPC 3 доходили до VPC 2 и VPC 1, 
#но не доходили из сети VPC 1 до VPC 2
resource "aws_route_table" "rt1" {
  tags = {
    Name = "rt1"
  }
  vpc_id = aws_vpc.vpc1.id
 
  route {
    cidr_block                = aws_vpc.vpc3.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering_vpc3_vpc1.id
  }
}

resource "aws_route_table_association" "rta_subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table" "rt2" {
  tags = {
    Name = "rt2"
  }
  vpc_id = aws_vpc.vpc2.id
 
  route {
    cidr_block                = aws_vpc.vpc3.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering_vpc3_vpc2.id
  }
}

resource "aws_route_table_association" "rta_subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt2.id
}

resource "aws_route_table" "rt3" {
  tags = {
    Name = "rt3"
  }
  vpc_id = aws_vpc.vpc3.id
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw3.id
  } 
 
  route {
    cidr_block                = aws_vpc.vpc1.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering_vpc3_vpc1.id
  }
  
  route {
    cidr_block                = aws_vpc.vpc2.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering_vpc3_vpc2.id
  }  
}

resource "aws_route_table_association" "rta_subnet3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.rt3.id
}

#Security groups
#https://repost.aws/questions/QUjtSNJ2CiRQamFnUJOWLWSw/ec2-instance-eni-sg-rules-mismatch-but-i-can-not-see-a-mismatch
#Проблема выше решилась пересозданием дефолтных групп
resource "aws_default_security_group" "sg1" {
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description      = "all in"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg1"
  }
}

resource "aws_default_security_group" "sg2" {
  vpc_id      = aws_vpc.vpc2.id

  ingress {
    description      = "all in"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg2"
  }
}

resource "aws_default_security_group" "sg3" {
  vpc_id      = aws_vpc.vpc3.id

  ingress {
    description      = "all in"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg3"
  }
}

#Instances for testing
resource "aws_instance" "instance1" {
  tags = {
    Name = "instance1"
  }
  ami           = "ami-02ea01341a2884771"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet1.id
}

resource "aws_instance" "instance2" {
  tags = {
    Name = "instance2"
  }
  ami           = "ami-02ea01341a2884771"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet2.id
}

resource "aws_instance" "instance3" {
  tags = {
    Name = "instance3"
  }
  ami           = "ami-02ea01341a2884771"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet3.id
}

