provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_instance" "my_instance" {
  ami           = "ami-0ae8f15ae66fe8cda"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  subnet_id = aws_subnet.my_subnet.id
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-static-website-bucket"
  website {
    index_document = "index.html"
  }
}

