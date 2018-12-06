terraform {
  backend "s3" {
    bucket = "terraform.grimoire"
    key    = "network.tfstate"
    region = "ca-central-1"
  }
}

provider "aws" {
  version = "~> 1.11"

  region = "ca-central-1"
}

resource "aws_vpc" "grimoire" {
  cidr_block = "10.1.0.0/16"

  assign_generated_ipv6_cidr_block = true
}

resource "aws_vpc_dhcp_options" "grimoire" {
  domain_name         = "grimoire.ca"
  domain_name_servers = ["AmazonProvidedDNS"]

  # Well-known IP from  <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/set-time.html>
  ntp_servers = ["169.254.169.123"]
}

resource "aws_vpc_dhcp_options_association" "grimoire" {
  vpc_id          = "${aws_vpc.grimoire.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.grimoire.id}"
}

resource "aws_subnet" "default" {
  vpc_id = "${aws_vpc.grimoire.id}"

  cidr_block      = "${cidrsubnet(aws_vpc.grimoire.cidr_block, 8, 1)}"
  ipv6_cidr_block = "${cidrsubnet(aws_vpc.grimoire.ipv6_cidr_block, 8, 1)}"

  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch         = true
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.grimoire.id}"
}

resource "aws_default_security_group" "default" {
  vpc_id = "${aws_vpc.grimoire.id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = "${aws_vpc.grimoire.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = "${aws_internet_gateway.default.id}"
  }
}

output "vpc_id" {
  value = "${aws_vpc.grimoire.id}"
}

output "subnet_id" {
  value = "${aws_subnet.default.id}"
}
