# aws vpc create 
resource "aws_vpc" "vpc1" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

}

# create aws vpc subnet1 a
resource "aws_subnet" "subnet1a" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"
}


# create internet gateway in vpc 
resource "aws_internet_gateway" "vpc1_igw" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "vpcigw"
  }
}

# create a route table public 
resource "aws_route_table" "Public_RT" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1_igw.id
  }

  tags = {
    Name = "default_route_table_association"
  }
}

# associate subnet1a with Public_RT table
resource "aws_route_table_association" "subnet1a_rt" {
  subnet_id      = aws_subnet.subnet1a.id
  route_table_id = aws_route_table.Public_RT.id
}





# aws instance create 
resource "aws_instance" "ins1" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.genrate_key.key_name
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.security2.id]
  subnet_id                   = aws_subnet.subnet1a.id
}
