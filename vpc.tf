resource "aws_vpc" "grimoire" {
  cidr_block = "10.1.0.0/16"

  assign_generated_ipv6_cidr_block = true
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

output "vpc_id" {
  value = "${aws_vpc.grimoire.id}"
}
