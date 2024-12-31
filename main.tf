# Summary
    # Create VPC
    # Create Internet Gateway and Attach to VPC
    # Create 2 Subnets - PVT and Pub
    # Create Public Route Tables and Edit routes for attaching RT with IG
    # Subnet Association b/w Pub RT and Pub Sub
    # Create SG and give permissions - Inbound (SSH) and Outbound (All traffic)
    # Create an Elastic IP for the NAT Gateway
    # Create NAT Gateway in public subnet
    # Create Private Route Tables and Edit routes for attaching RT with IG
    # Subnet Association b/w Pvt RT and Pvt Sub
    # Launch EC2 in public

# Create VPC

resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev_vpc"
  }
}

# Create Internet Gateway and Attach to VPC

resource "aws_internet_gateway" "dev_ig" {
  vpc_id = aws_vpc.dev_vpc.id ## Attach VPC

  tags = {
    Name = "dev_ig"
  }
}

# Create 2 Subnets

resource "aws_subnet" "dev_pub_sub" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.0.0.0/18"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "dev_pub_sub"
  }
}

resource "aws_subnet" "dev_pvt_sub" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.0.64.0/18"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "dev_pvt_sub"
  }
}

# Create Public Route Tables and Edit routes for attaching RT with IG

resource "aws_route_table" "dev_pub_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_ig.id # Edit Routes
  }
  tags = {
    Name = "dev_pub_rt"
  }
}

# Subnet Association b/w Pub RT and Pub Sub

resource "aws_route_table_association" "pub_sub_association" {
  subnet_id      = aws_subnet.dev_pub_sub.id
  route_table_id = aws_route_table.dev_pub_rt.id
}

# Create SG and give permissions for SSH - Inbound (SSH) and Outbound (All traffic)

resource "aws_security_group" "dev_vpc_sg_allow_ssh" {
  name        = "allow_dev_ssh"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.dev_vpc.id

# Inbound rule for SSH (port 22)
  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22 # From port and to port allows you to define a range of ports. 
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with a restricted CIDR if needed
  }
  # Outbound rule for all traffic, good to explicitly define
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev_vpc_sg_allow_ssh"
  }
}

# Create an Elastic IP for the NAT Gateway

resource "aws_eip" "dev_nat_eip" {
  domain = "vpc" # This ensures the EIP is for VPC use, vpc = true attribute is no longer supported for specifying Elastic IP allocation in Terraform

  tags = {
    Name = "dev_nat_eip"
  }
}

# Create NAT Gateway in public subnet

resource "aws_nat_gateway" "dev_pub_sub_nat_gw" {
  allocation_id = aws_eip.dev_nat_eip.id
  subnet_id     = aws_subnet.dev_pub_sub.id

  tags = {
    Name = "dev_pub_sub_nat_gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  # As EIP in VPC requires a IG, NAT gateway will wait
  # until the IG is created/provisioned first
  depends_on = [aws_internet_gateway.dev_ig]
}

# Create Private Route Tables and Edit routes for attaching RT with IG

resource "aws_route_table" "dev_pvt_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.dev_pub_sub_nat_gw.id # Edit Routes
  }
  tags = {
    Name = "dev_pvt_rt"
  }
}

# Subnet Association b/w Pvt RT and Pvt Sub

resource "aws_route_table_association" "pvt_sub_association" {
  subnet_id      = aws_subnet.dev_pvt_sub.id
  route_table_id = aws_route_table.dev_pvt_rt.id
}