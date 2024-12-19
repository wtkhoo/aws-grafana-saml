# Variables
variable "name" {
  description = "Prefix name for resources"
  type        = string
  default     = "grafana-demo"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

data "aws_availability_zones" "az" {
  state = "available"
}

data "aws_ssm_parameter" "aml_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Barebone VPC
resource "aws_vpc" "demo" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

# Private subnets
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.demo.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone = element(data.aws_availability_zones.az.names, 0)

  tags = {
    Name = "${var.name}-private-subnet-a"
  }
}

# Route table and associations
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "${var.name}-private-rt"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

# EC2 for demo
resource "aws_instance" "linux" {
  ami                    = data.aws_ssm_parameter.aml_latest_ami.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_a.id

  tags = {
    Name = "${var.name}-linux",
  }
}

# Outputs
output "ec2_linux_instance_id" {
  description = "The instance ID of the Linux demo instance"
  value       = aws_instance.linux.id
}
