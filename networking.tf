resource "aws_vpc" "main_vpc" {
  cidr_block = var.main_vpc_cidr
  tags = {
    Name = "${var.unique_prefix}_main_vpc"
  }
}

resource "aws_subnet" "main_subnet_a" {
  availability_zone = "${var.region}a"
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = cidrsubnet(var.main_vpc_cidr, 8, 1)
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.unique_prefix}_main_sub_a"
  }
}

resource "aws_subnet" "main_subnet_b" {
  availability_zone = "${var.region}b"
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = cidrsubnet(var.main_vpc_cidr, 8, 2)
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.unique_prefix}_main_sub_b"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "${var.unique_prefix}_main_igw"
  }
}

resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "${var.unique_prefix}_main_rt"
  }
}

resource "aws_route_table_association" "subnet_association_a" {
  subnet_id      = aws_subnet.main_subnet_a.id
  route_table_id = aws_route_table.main_rt.id
}

resource "aws_route_table_association" "subnet_association_b" {
  subnet_id      = aws_subnet.main_subnet_b.id
  route_table_id = aws_route_table.main_rt.id
}

