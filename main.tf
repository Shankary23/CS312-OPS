
# Automatically grab the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 1. NETWORKING (VPC, Subnet, Gateway, Route)

resource "aws_vpc" "minecraft_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "MinecraftVPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.minecraft_vpc.id

  tags = {
    Name = "MinecraftIGW"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.minecraft_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true 
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "MinecraftPublicSubnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.minecraft_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "MinecraftPublicRT"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 2. SECURITY GROUP (Firewall Rules)

resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft_server_sg"
  description = "Allow SSH for admin and TCP 25565 for Minecraft clients"
  vpc_id      = aws_vpc.minecraft_vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    description = "Minecraft TCP"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MinecraftSG"
  }
}

# 3. EC2 INSTANCE

resource "aws_instance" "minecraft_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id  
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]
  key_name               = "vockey"

  iam_instance_profile = "LabInstanceProfile"

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "MinecraftServer"
  }
}

# 4. ECR & S3 (For Images and World Data)

resource "aws_ecr_repository" "minecraft_repo" {
  name                 = "ops3-minecraft-repo"
  image_tag_mutability = "MUTABLE"
  # force_delete = true
}
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "minecraft_world_data" {
  bucket        = "ops3-minecraft-world-data-${random_id.bucket_suffix.hex}"
  # force_destroy = true
  
}