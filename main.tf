terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.60.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "public-sub" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-sub"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "my-route" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
}

resource "aws_route_table_association" "pub-sub" {
  route_table_id = aws_route_table.my-route.id
  subnet_id      = aws_subnet.public-sub.id
}

resource "aws_security_group" "a-sg" {
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "a-sg"
  }
}
resource "aws_security_group" "test2" {
  name        = "test2"
  description = "allow all traffic"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description      = "port 80 "
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
   ingress {
    description      = "port 80 "
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
   egress {
    description      = "port 80 "
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    name = "test2"
  }
}
resource "aws_instance" "my-inst" {
  ami = "ami-0ae8f15ae66fe8cda"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public-sub.id
  security_groups = [aws_security_group.test2]
  tags = {
    Name = "my-inst"
  }
  associate_public_ip_address = true
}

resource "random_id" "id-random" {
  byte_length = 8
}

resource "aws_s3_bucket" "static-proj" {
  bucket = "static-proj12345678"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "pub-access" {
  bucket = aws_s3_bucket.static-proj.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "static-policy" {
  bucket = aws_s3_bucket.static-proj.id
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Sid       = "PublicReadGetObject",
          Effect    = "Allow",
          Principal = "*",
          Action = [
            "s3:GetObject"
          ],
          Resource = [
            "arn:aws:s3:::${aws_s3_bucket.static-proj.id}/*"
          ]
        }
      ]
    }
  )
}

resource "aws_s3_bucket_website_configuration" "static-proj" {
  bucket = aws_s3_bucket.static-proj.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.static-proj.bucket
  source = "./index.html"
  key    = "index.html"
  content_type = "text/html"
}

# resource "aws_s3_object" "style_css" {
#   bucket = aws_s3_bucket.static-proj.bucket
#   source = "./style.css"
#   key    = "style.css"
#   content_type = "text/css"
# }

output "link" {
  value = aws_s3_bucket_website_configuration.static-proj.website_endpoint
}




