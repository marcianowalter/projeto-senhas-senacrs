provider "aws" {
  region = "us-east-1"
}

# Buscar AMI mais recente do Ubuntu 20.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Criar VPC (necessário porque sua conta não tem VPC padrão)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Criar Subnet pública
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Associar rota à subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.rt.id
}

# Criar par de chaves p/ SSH
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("${path.module}/mykey.pub")

  lifecycle {
    ignore_changes = [public_key] # evita erro de duplicação
  }
}

# Security Group para liberar SSH e porta da aplicação
resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Permite SSH e porta 5000"
  vpc_id      = aws_vpc.main.id   # ✅ necessário

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Aplicacao Flask"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Criar instância EC2
resource "aws_instance" "app_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "minha-chave"
  subnet_id              = aws_subnet.main_subnet.id   # ✅ necessario
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "GerenciadorSenhas"
  }
}

# Output do IP público
output "ec2_public_ip" {
  value = aws_instance.app_instance.public_ip
}
