resource "aws_vpc" "main_vpc" {
  cidr_block = var.main_vpc_cidr
  tags = {
    Name = "${var.unique_prefix}_main_vpc"
  }
}

resource "aws_subnet" "main_subnet" {
  count      = length(data.aws_availability_zones.azs.names)
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = cidrsubnet(var.main_vpc_cidr, 8, count.index)
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.unique_prefix}_main_sub_${count.index + 1}"
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

resource "aws_route_table_association" "subnet_association" {
  count = length(data.aws_availability_zones.azs.names)
  subnet_id      = element(aws_subnet.main_subnet.*.id,count.index)
  route_table_id = aws_route_table.main_rt.id
}



