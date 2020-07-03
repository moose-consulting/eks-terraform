resource "aws_vpc" "cluster" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name        = "eks-${terraform.workspace}"
    ManagedBy   = "Terraform"
    Environment = terraform.workspace
  }
}

data "aws_availability_zones" "cluster" {
  filter {
    name   = "region-name"
    values = [var.region]
  }
}

resource "aws_subnet" "cluster" {
  count = length(data.aws_availability_zones.cluster.zone_ids)

  vpc_id                  = aws_vpc.cluster.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.cluster.names[count.index]
  map_public_ip_on_launch = "true"

  tags = {
    Name                                 = "eks-${terraform.workspace}"
    ManagedBy                            = "Terraform"
    Environment                          = terraform.workspace
    "kubernetes.io/cluster/eks-${terraform.workspace}" = "shared"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.cluster.id

  tags = {
    Name        = "eks-${terraform.workspace}"
    ManagedBy   = "Terraform"
    Environment = terraform.workspace
  }
}

resource "aws_route53_zone" "cluster" {
  name = "${terraform.workspace}.internal"
  vpc {
    vpc_id     = aws_vpc.cluster.id
    vpc_region = var.region
  }

  tags = {
    Name        = "eks-${terraform.workspace}"
    ManagedBy   = "Terraform"
    Environment = terraform.workspace
  }
}

resource "aws_route_table" "routes" {
  vpc_id = aws_vpc.cluster.id

  tags = {
    Name        = "eks-${terraform.workspace}"
    ManagedBy   = "Terraform"
    Environment = terraform.workspace
  }
}

resource "aws_route" "egress" {
  route_table_id         = aws_route_table.routes.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "cluster" {
  count = length(aws_subnet.cluster)

  subnet_id      = aws_subnet.cluster[count.index].id
  route_table_id = aws_route_table.routes.id
}

resource "aws_security_group" "allow_tls" {
  name   = "eks-${terraform.workspace}-control-plane"
  vpc_id = aws_vpc.cluster.id

  tags = {
    Name        = "eks-${terraform.workspace}-control-plane"
    ManagedBy   = "Terraform"
    Environment = terraform.workspace
  }
}
