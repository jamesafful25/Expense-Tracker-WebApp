# --------------------------------------------------
# 1. VPC
# --------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


# --------------------------------------------------
# 2. Internet Gateway
# --------------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}


# --------------------------------------------------
# 3. Public Subnets
# --------------------------------------------------

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-${count.index + 1}"
    Tier = "Public"
  }
}


# --------------------------------------------------
# 4. Private Application Subnets
# --------------------------------------------------

resource "aws_subnet" "private_app" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-app-${count.index + 1}"
    Tier = "Private-Application"
  }
}


# --------------------------------------------------
# 5. Private Database Subnets
# --------------------------------------------------

resource "aws_subnet" "private_db" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-db-${count.index + 1}"
    Tier = "Private-Database"
  }
}


# --------------------------------------------------
# 6. Elastic IP for NAT Gateway
# --------------------------------------------------

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-eip"
  }
}


# --------------------------------------------------
# 7. NAT Gateway
# --------------------------------------------------

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [
    aws_internet_gateway.main
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-nat"
  }
}


# --------------------------------------------------
# 8. Public Route Table
# --------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}


# --------------------------------------------------
# 9. Associate Public Subnets with Public Route Table
# --------------------------------------------------

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# --------------------------------------------------
# 10. Private Application Route Table
# --------------------------------------------------

resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-app-rt"
  }
}


# --------------------------------------------------
# 11. Associate Application Subnets with Private Route Table
# --------------------------------------------------

resource "aws_route_table_association" "private_app" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app.id
}


# --------------------------------------------------
# 12. Private Database Route Table
# --------------------------------------------------

resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-db-rt"
  }
}


# --------------------------------------------------
# 13. Associate Database Subnets with Private Route Table
# --------------------------------------------------

resource "aws_route_table_association" "private_db" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db.id
}