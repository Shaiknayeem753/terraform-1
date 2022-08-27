provider "aws" {
  region = "ap-south-1"

}

#Create the VPC
 resource "aws_vpc" "Main" {                # Creating VPC here
   cidr_block       = "${var.main_vpc_cidr}"     # Defining the CIDR block use 10.0.0.0/24 for demo
   instance_tenancy = "default"
 }
# Create Internet Gateway and attach it to VPC
 resource "aws_internet_gateway" "IGW" {    # Creating Internet Gateway
    vpc_id =  aws_vpc.Main.id               # vpc_id will be generated after we create VPC
 }
# Create a Public Subnets.
 resource "aws_subnet" "publicsubnets" {    # Creating Public Subnets
   vpc_id =  aws_vpc.Main.id
   cidr_block = "${var.public_subnets}"        # CIDR block of public subnets
   map_public_ip_on_launch = true
 #  aws_availability_zone = "ap-south-1b"
 }
 #Create a Private Subnet                   # Creating Private Subnets
 resource "aws_subnet" "privatesubnets" {
   vpc_id =  aws_vpc.Main.id
   cidr_block = "${var.private_subnets}"          # CIDR block of private subnets
 }
# Route table for Public Subnet's
 resource "aws_route_table" "PublicRT" {    # Creating RT for Public Subnet
    vpc_id =  aws_vpc.Main.id
         route {
    cidr_block = "0.0.0.0/0"               # Traffic from Public Subnet reaches Internet via Internet Gateway
    gateway_id = aws_internet_gateway.IGW.id
     }
 }
 # Route table for Private Subnet's
 resource "aws_route_table" "PrivateRT" {    # Creating RT for Private Subnet
   vpc_id = aws_vpc.Main.id
  # route {
  # cidr_block = "0.0.0.0/0"             # Traffic from Private Subnet reaches Internet via NAT Gateway
   #gateway_id = "${var.main_vpc_cidr}"
  # }
 }
# Route table Association with Public Subnet's
 resource "aws_route_table_association" "PublicRTassociation" {
    subnet_id = aws_subnet.publicsubnets.id
    route_table_id = aws_route_table.PublicRT.id
 }
# Route table Association with Private Subnet's
 resource "aws_route_table_association" "PrivateRTassociation" {
    subnet_id = aws_subnet.privatesubnets.id
    route_table_id = aws_route_table.PrivateRT.id
 }
 
 resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.publicsubnets.id
  private_ips = ["${var.private_ips}"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "ec2" {
  ami           = "${var.ami}" # us-west-2
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  security_groups = aws_security_group.sg.id

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
      }
  
}


resource "aws_security_group" "sg" {
  name        = "alltraffic"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.Main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "all traffic"
  }
}