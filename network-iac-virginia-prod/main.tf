terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}


#% terraform import aws_vpc.vpc-hub-inspection vpc-0b13f3cdb939a1d5e
resource "aws_vpc" "vpc-hub-inspection" {
  cidr_block           = "10.27.16.0/21"
  instance_tenancy     = "default"
  enable_dns_hostnames = "false"

  tags = {
    Name            = "vpc-hub-inspection"
    managed-by-ipam = "false"
  }
}
#DEFINICIONES DE SUBNETS PARA LA VPC 
#AZ1
#$ terraform import aws_subnet.snet-wan-fgt-use1-1 subnet-035aa35052dd884ca
resource "aws_subnet" "snet-wan-fgt-use1-1" {
  vpc_id            = "vpc-0b13f3cdb939a1d5e"
  availability_zone = "us-east-1a"
  cidr_block        = "10.27.16.0/24"
  tags = {
    Name = "snet-wan-fgt-use1-1"
  }

}


#$ terraform import aws_subnet.snet-tgw-att-use1-1 subnet-0cc2bb81030aa1ed8
resource "aws_subnet" "snet-tgw-att-use1-1" {
  vpc_id            = "vpc-0b13f3cdb939a1d5e"
  availability_zone = "us-east-1a"
  cidr_block        = "10.27.20.0/27"
  tags = {
    Name = "snet-tgw-att-use1-1"
  }

}

#$ terraform import aws_subnet.snet-lan-fgt-use1-1 subnet-0c9d2a401b4d52b24
resource "aws_subnet" "snet-lan-fgt-use1-1" {
  vpc_id            = "vpc-0b13f3cdb939a1d5e"
  availability_zone = "us-east-1a"
  cidr_block        = "10.27.18.0/24"
  tags = {
    Name = "snet-lan-fgt-use1-1"
  }

}

#AZ2
#$ terraform import aws_subnet.snet-wan-fgt-use1-2 subnet-0a36c7bb983f5943a
resource "aws_subnet" "snet-wan-fgt-use1-2" {
  vpc_id            = "vpc-0b13f3cdb939a1d5e"
  availability_zone = "us-east-1b"
  cidr_block        = "10.27.17.0/24"
  tags = {
    Name = "snet-wan-fgt-use1-2"
  }

}


#$ terraform import aws_subnet.snet-tgw-att-use1-2 subnet-093ad655e05ec031f
resource "aws_subnet" "snet-tgw-att-use1-2" {
  vpc_id            = "vpc-0b13f3cdb939a1d5e"
  availability_zone = "us-east-1b"
  cidr_block        = "10.27.20.32/27"
  tags = {
    Name = "snet-tgw-att-use1-2"
  }

}


#$ terraform import aws_subnet.snet-lan-fgt-use1-2 subnet-00058cb92a4140cf4
resource "aws_subnet" "snet-lan-fgt-use1-2" {
  vpc_id            = "vpc-0b13f3cdb939a1d5e"
  availability_zone = "us-east-1b"
  cidr_block        = "10.27.19.0/24"
  tags = {
    Name = "snet-lan-fgt-use1-2"
  }

}

#Subnet agregada via tf para sincronizacion del HA y management del forti de la AZ1
resource "aws_subnet" "hasync-hamgmt-az1" {
  vpc_id            = "vpc-0b13f3cdb939a1d5e"
  availability_zone = "us-east-1a"
  cidr_block        = "10.27.20.64/28"
  tags = {
    Name = "hasync-hamgmt-az1"
  }

}

#Subnet agregada via tf para sincronizacion del HA y management del forti de la AZ2-
resource "aws_subnet" "hasync-hamgmt-az2" {
  vpc_id            = "vpc-0b13f3cdb939a1d5e"
  availability_zone = "us-east-1b"
  cidr_block        = "10.27.20.80/28"
  tags = {
    Name = "hasync-hamgmt-az2"
  }

}

#% terraform import aws_route_table.hub-rt-internal-prod-vpc-inspection rtb-04206bbccd8a7252d
resource "aws_route_table" "hub-rt-internal-prod-vpc-inspection" {
  vpc_id = aws_vpc.vpc-hub-inspection.id
  tags = {
    Name = "hub-rt-internal-prod-vpc-inspection"
  }
}

#% terraform import aws_route_table_association.lan-az1 subnet-00058cb92a4140cf4/rtb-04206bbccd8a7252d

resource "aws_route_table_association" "lan-az1" {
  subnet_id      = aws_subnet.snet-lan-fgt-use1-2.id
  route_table_id = aws_route_table.hub-rt-internal-prod-vpc-inspection.id
}

# terraform import aws_route_table_association.lan-az2 subnet-0c9d2a401b4d52b24/rtb-04206bbccd8a7252d

resource "aws_route_table_association" "lan-az2" {
  subnet_id      = aws_subnet.snet-lan-fgt-use1-1.id
  route_table_id = aws_route_table.hub-rt-internal-prod-vpc-inspection.id
}



##########

#% terraform import aws_route_table.hub-rt-external-az1-prod-vpc-inspection rtb-0d2e35f6565c4524c
resource "aws_route_table" "hub-rt-external-az1-prod-vpc-inspection" {
  vpc_id = aws_vpc.vpc-hub-inspection.id
  tags = {
    Name = "hub-rt-external-az1-prod-vpc-inspection"
  }
}

#% terraform import aws_route.def-internet rtb-0d2e35f6565c4524c_0.0.0.0/0
resource "aws_route" "def-internet" {
  route_table_id         = aws_route_table.hub-rt-external-az1-prod-vpc-inspection.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "igw-020ecaf1a71eca15d"
}

# terraform import aws_route_table_association.wan-az1 subnet-035aa35052dd884ca/rtb-0d2e35f6565c4524c
resource "aws_route_table_association" "wan-az1" {
  subnet_id      = aws_subnet.snet-wan-fgt-use1-1.id
  route_table_id = aws_route_table.hub-rt-external-az1-prod-vpc-inspection.id
}


###########

#% terraform import aws_route_table.hub-rt-external-az2-prod-vpc-inspection rtb-07919712286c33c64
resource "aws_route_table" "hub-rt-external-az2-prod-vpc-inspection" {
  vpc_id = aws_vpc.vpc-hub-inspection.id
  tags = {
    Name = "hub-rt-external-az2-prod-vpc-inspection"
  }
}

# terraform import aws_route_table_association.wan-az2 subnet-0a36c7bb983f5943a/rtb-07919712286c33c64
resource "aws_route_table_association" "wan-az2" {
  subnet_id      = aws_subnet.snet-wan-fgt-use1-2.id
  route_table_id = aws_route_table.hub-rt-external-az2-prod-vpc-inspection.id
}




###########import rtb-tgw- no esta asociado a ninguna subnet
#% terraform import aws_route_table.tgw-rtb rtb-08beb46a88998f03d
resource "aws_route_table" "tgw-rtb" {
  vpc_id = aws_vpc.vpc-hub-inspection.id
  tags = {
    Name = "hub-rt-tgw-prod-vpc-inspection"
  }
}


############### importar la rtb default

#% terraform import aws_route_table.default-rtb rtb-0885790e0f4963e3b
resource "aws_route_table" "default-rtb" {
  vpc_id = aws_vpc.vpc-hub-inspection.id
  tags = {
    Name = "default-rt-vpc-hub-inspection"
  }
}

#% terraform import aws_route.to-dispositivo rtb-0885790e0f4963e3b_10.0.0.0/8
resource "aws_route" "to-dispositivo" {
  route_table_id         = aws_route_table.default-rtb.id
  destination_cidr_block = "10.0.0.0/8"
  network_interface_id   = "eni-048ec197c69832ce5"
}

#Falta importar IGW y TGW