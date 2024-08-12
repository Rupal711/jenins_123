variable "region" {
  type        = string
  description = "Define Region For Build Aws Infra"
  default     = "us-east-1"
}


variable "instance_ami" {
  type        = string
  description = "AMI ID for the EC2 instance"
  default     = "ami-04a81a99f5ec58529"
}

variable "instance_type" {
  type        = string
  description = "Define Instance Type"
  default     = "t2.micro"
}

variable "vpc_cidr_block" {
  type        = string
  description = "Define Vpc Cidr Block"
  default     = "10.0.0.0/16"
}

variable "vpc_subnet_cidr" {
  type        = list(any)
  description = " Define Subnet1 Cidr Block "
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

