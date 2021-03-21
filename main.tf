provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}#------------- Deploy VPC-----------#
resource "aws_vpc" "iac_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = truetags {
    Name = "iac_vpc"
  }
}# Deploy 1 internet gatewayresource "aws_internet_gateway" "iac_internet_gateway" {
  vpc_id = "${aws_vpc.iac_vpc.id}"tags {
    Name = "iac_igw"
  }
}# Deploy 2 Route tablesresource "aws_route_table" "iac_public_rt" {
  vpc_id = "${aws_vpc.iac_vpc.id}"route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.iac_internet_gateway.id}"
  }tags {
    Name = "iac_public_rtb"
  }
}resource "aws_default_route_table" "iac_private_rt" {
  default_route_table_id = "${aws_vpc.iac_vpc.default_route_table_id}"tags {
    Name = "iac_private_rtb"
  }
}#deploy subnets 
resource "aws_subnet" "iac_public1_subnet" {
  vpc_id                  = "${aws_vpc.iac_vpc.id}"
  cidr_block              = "${var.cidrs["public1"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"tags {
    Name = "iac_public1"
  }
}resource "aws_subnet" "iac_public2_subnet" {
  vpc_id                  = "${aws_vpc.iac_vpc.id}"
  cidr_block              = "${var.cidrs["public2"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"tags {
    Name = "iac_public2"
  }
}resource "aws_subnet" "iac_private1_subnet" {
  vpc_id                  = "${aws_vpc.iac_vpc.id}"
  cidr_block              = "${var.cidrs["private1"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"tags {
    Name = "iac_private1"
  }
}resource "aws_subnet" "iac_private2_subnet" {
  vpc_id                  = "${aws_vpc.iac_vpc.id}"
  cidr_block              = "${var.cidrs["private2"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"tags {
    Name = "iac_private2"
  }
}# Subnet Associationsresource "aws_route_table_association" "iac_public_assoc" {
  subnet_id      = "${aws_subnet.iac_public1_subnet.id}"
  route_table_id = "${aws_route_table.iac_public_rt.id}"
}resource "aws_route_table_association" "iac_public2_assoc" {
  subnet_id      = "${aws_subnet.iac_public2_subnet.id}"
  route_table_id = "${aws_route_table.iac_public_rt.id}"
}resource "aws_route_table_association" "iac_private1_assoc" {
  subnet_id      = "${aws_subnet.iac_private1_subnet.id}"
  route_table_id = "${aws_default_route_table.iac_private_rt.id}"
}resource "aws_route_table_association" "iac_private2_assoc" {
  subnet_id      = "${aws_subnet.iac_private2_subnet.id}"
  route_table_id = "${aws_default_route_table.iac_private_rt.id}"
}
