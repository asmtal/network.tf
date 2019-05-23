resource "aws_subnet" "default" {
  vpc_id = aws_vpc.grimoire.id

  cidr_block      = cidrsubnet(aws_vpc.grimoire.cidr_block, 8, 1)
  ipv6_cidr_block = cidrsubnet(aws_vpc.grimoire.ipv6_cidr_block, 8, 1)

  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch         = true

  tags = {
    Project = "network.tf"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.grimoire.id

  tags = {
    Project = "network.tf"
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.grimoire.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.default.id
  }

  tags = {
    Project = "network.tf"
  }
}

output "subnet_id" {
  value = aws_subnet.default.id
}

