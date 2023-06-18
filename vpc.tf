# Create a VPC

resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "eks-vpc"
  }
}

# Create Internet gateway
resource "aws_internet_gateway" "eks_vpc_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-vpc-igw"
  }
}

# Create Subnets
# Public Subnet 1
resource "aws_subnet" "eks_vpc_public_subnet1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                                = "eks-vpc-public-subnet1"
    "kubernetes.io/cluster/project-eks" = "shared"
    "kubernetes.io/role/elb"            = 1
  }
}

# Public Subnet 2
resource "aws_subnet" "eks_vpc_public_subnet2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                                = "eks-vpc-public-subnet2"
    "kubernetes.io/cluster/project-eks" = "shared"
    "kubernetes.io/role/elb"            = 1
  }
}

# Private Subnet 1
resource "aws_subnet" "eks_vpc_private_subnet1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name                                = "eks-vpc-private-subnet1"
    "kubernetes.io/cluster/project-eks" = "shared"
    "kubernetes.io/role/internal-elb"   = 1
  }
}

# Private Subnet 2
resource "aws_subnet" "eks_vpc_private_subnet2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name                                = "eks-vpc-private-subnet2"
    "kubernetes.io/cluster/project-eks" = "shared"
    "kubernetes.io/role/internal-elb"   = 1
  }
}

# Create eip
# eip 1
resource "aws_eip" "nat_eip1" {
  depends_on = [aws_internet_gateway.eks_vpc_igw]

}

# eip 2
resource "aws_eip" "nat_eip2" {
  depends_on = [aws_internet_gateway.eks_vpc_igw]
}

# Create Nat gateway
# Nat 1
resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.eks_vpc_public_subnet1.id

  tags = {
    Name = "Nat1"
  }
}

# Nat 2
resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.eks_vpc_public_subnet2.id

  tags = {
    Name = "Nat2"
  }
}

# Create Route Table
# Public route table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_vpc_igw.id
  }

  tags = {
    Name = "Public-route"
  }
}

# Private route table 1
resource "aws_route_table" "private_route1" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat1.id
  }

  tags = {
    Name = "Private-route1"
  }
}

# Private route table 2
resource "aws_route_table" "private_route2" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat2.id
  }

  tags = {
    Name = "Private-route2"
  }
}

# Create route table association
# route table association for public subnet 1
resource "aws_route_table_association" "public_subnet1_rta" {
  subnet_id      = aws_subnet.eks_vpc_public_subnet1.id
  route_table_id = aws_route_table.public_route.id
}

# route table association for public subnet 2
resource "aws_route_table_association" "public_subnet2_rta" {
  subnet_id      = aws_subnet.eks_vpc_public_subnet2.id
  route_table_id = aws_route_table.public_route.id
}

# route table association for private subnet 1
resource "aws_route_table_association" "private_subnet1_rta" {
  subnet_id      = aws_subnet.eks_vpc_private_subnet1.id
  route_table_id = aws_route_table.private_route1.id
}

# route table association for private subnet 2
resource "aws_route_table_association" "private_subnet2_rta" {
  subnet_id      = aws_subnet.eks_vpc_private_subnet2.id
  route_table_id = aws_route_table.private_route2.id
}
