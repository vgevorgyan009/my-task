// network creating

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name : "${var.env_prefix}-igw"
  }
}

data "aws_availability_zones" "working" {}

resource "aws_subnet" "public-subnets" {
  count = length(var.public_subnet_cidr_blocks)
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = element(var.public_subnet_cidr_blocks, count.index)
  availability_zone = data.aws_availability_zones.working.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env_prefix}-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "my-public-subnets-route-table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
  tags = {
    Name : "${var.env_prefix}-public-rtb"
  }
}

resource "aws_route_table_association" "for_public_subnets" {
  count          = 3
  subnet_id      = element(aws_subnet.public-subnets[*].id, count.index)
  route_table_id = aws_route_table.my-public-subnets-route-table.id
}

resource "aws_eip" "nat_gateway_eips" {
  count = 3
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat_gateways" {
  count         = 3
  allocation_id = aws_eip.nat_gateway_eips[count.index].id
  subnet_id     = element(aws_subnet.public-subnets[*].id, count.index)
  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }
}

resource "aws_subnet" "private-subnets" {
  count = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = element(var.private_subnet_cidr_blocks, count.index)
  availability_zone = data.aws_availability_zones.working.names[count.index]
  tags = {
    Name = "${var.env_prefix}-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "private-subnets-route-tables" {
  count      = 3
  vpc_id     = aws_vpc.my-vpc.id
  tags = {
    Name = "private-route-table-${count.index + 1}"
  }
}

resource "aws_route" "nat_gateway_route" {
  count                = 3
  route_table_id       = aws_route_table.private-subnets-route-tables[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id       = element(aws_nat_gateway.nat_gateways[*].id, count.index)
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = 3
  subnet_id      = element(aws_subnet.private-subnets[*].id, count.index)
  route_table_id = aws_route_table.private-subnets-route-tables[count.index].id
}

