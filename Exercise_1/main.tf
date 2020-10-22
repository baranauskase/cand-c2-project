# TODO: Designate a cloud provider, region, and credentials
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}


resource "aws_vpc" "udacity_cand_c2_vpc" {
  cidr_block = var.vpcCIDRblock
  instance_tenancy = var.instanceTenancy 
  enable_dns_support = var.dnsSupport 
  enable_dns_hostnames = var.dnsHostNames

  tags = {
    environment = "dev"
  }
}

resource "aws_subnet" "udacity_cand_c2_public_subnet_1" {
  vpc_id                  = aws_vpc.udacity_cand_c2_vpc.id
  cidr_block              = var.subnetCIDRblock
  map_public_ip_on_launch = var.mapPublicIP 
  availability_zone       = var.availabilityZone
  tags = {
    environment = "dev"
  }
}

resource "aws_route_table" "udacity_cand_c2_public_rt" {
  vpc_id = aws_vpc.udacity_cand_c2_vpc.id
  tags = {
    environment = "dev"
  }
}

resource "aws_route_table_association" "udacity_cand_c2_public_rt_association" {
  subnet_id = aws_subnet.udacity_cand_c2_public_subnet_1.id
  route_table_id = aws_route_table.udacity_cand_c2_public_rt.id
}

resource "aws_internet_gateway" "udacity_cand_c2_gw" {
  vpc_id = aws_vpc.udacity_cand_c2_vpc.id
  tags = {
    environment = "dev"
  }
}

resource "aws_route" "udacity_cand_c2_internet_access" {
  route_table_id = aws_route_table.udacity_cand_c2_public_rt.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id = aws_internet_gateway.udacity_cand_c2_gw.id
}

resource "aws_security_group" "udacity_cand_c2_sg" {
  vpc_id       = aws_vpc.udacity_cand_c2_vpc.id
  name         = "SG for EC2 instances"
  description  = "SG for EC2 instances"
  
  # allow ingress of port 22
  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  } 
  
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    environment = "dev"
  }
}

# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_launch_configuration" "udacity_cand_c2_t2_lc" {
  name_prefix = "udacity_t2_"

  image_id = "ami-0a669382ea0feb73a"
  instance_type = "t2.micro"
  key_name = "eb-macbook"

  security_groups = [ aws_security_group.udacity_cand_c2_sg.id ]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "udacity_cand_c2_t2_asg" {
  name = "${aws_launch_configuration.udacity_cand_c2_t2_lc.name}-asg"

  min_size = 4
  desired_capacity = 4
  max_size = 4
  
  launch_configuration = aws_launch_configuration.udacity_cand_c2_t2_lc.name
  vpc_zone_identifier  = [
    aws_subnet.udacity_cand_c2_public_subnet_1.id
  ]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }
}

# TODO: provision 2 m4.large EC2 instances named Udacity M4
# resource "aws_launch_configuration" "udacity_cand_c2_m4_lc" {
#   name_prefix = "udacity_m4_"

#   image_id = "ami-0a669382ea0feb73a"
#   instance_type = "m4.large"
#   key_name = "eb-macbook"

#   security_groups = [ aws_security_group.udacity_cand_c2_sg.id ]
#   associate_public_ip_address = true

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_autoscaling_group" "udacity_cand_c2_m4_asg" {
#   name = "${aws_launch_configuration.udacity_cand_c2_m4_lc.name}-asg"

#   min_size = 2
#   desired_capacity = 2
#   max_size = 2
  
#   launch_configuration = aws_launch_configuration.udacity_cand_c2_m4_lc.name
#   vpc_zone_identifier  = [
#     aws_subnet.udacity_cand_c2_public_subnet_1.id
#   ]

#   # Required to redeploy without an outage.
#   lifecycle {
#     create_before_destroy = true
#   }
# }


