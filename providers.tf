

#Connect with aws account using secret_key and access_id 
provider "aws" {
  region     = var.region

}

# Genrate Aws key pair 
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "genrate_key" {
  key_name   = "test"
  public_key = tls_private_key.example.public_key_openssh
  
}

# output collect key 
output "private_key" {
  value     = tls_private_key.example.private_key_pem
  sensitive = true
}

