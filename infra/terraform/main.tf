# ============================================================
# Innovatech Chile - EP3 DevOps (ISY1101)
# Orquestación con AWS EKS (Elastic Kubernetes Service)
#
# Incluye:
#   - VPC con subredes públicas y privadas en 2 AZ
#   - Internet Gateway + NAT Gateway
#   - Security Group para los nodos EKS
#   - Clúster EKS + Node Group (usa LabRole de AWS Academy)
#   - 3 repositorios ECR (frontend, backend-ventas, backend-despachos)
#   - Log groups de CloudWatch
#
# Diseñado para correr dentro de un AWS Academy Learner Lab:
#   - No crea roles IAM propios (Academy no lo permite); reutiliza "LabRole"
#     tanto para el cluster_role como para el node_role.
#   - El Node Group parte con 1 nodo (desired_size = 1) para evitar
#     bloqueos al crearlo, con margen para escalar a 2 (max_size = 2).
# ============================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ------------------------------------------------------------
# Data sources
# ------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

# AWS Academy entrega el rol "LabRole" con los permisos necesarios.
# No es posible (ni se debe intentar) crear roles IAM nuevos en el Learner Lab.
data "aws_iam_role" "labrole" {
  name = "LabRole"
}

# ------------------------------------------------------------
# VPC
# ------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
    Stage   = "EP3"
  }
}

# ------------------------------------------------------------
# Subredes públicas (Load Balancer del frontend y NAT Gateway)
# ------------------------------------------------------------

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.project_name}-public-a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
    Tier                                        = "public"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.project_name}-public-b"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
    Tier                                        = "public"
  }
}

# ------------------------------------------------------------
# Subredes privadas (nodos EKS y pods: backends + mysql)
# ------------------------------------------------------------

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.30.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name                                        = "${var.project_name}-private-a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
    Tier                                        = "private"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.40.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name                                        = "${var.project_name}-private-b"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
    Tier                                        = "private"
  }
}

# ------------------------------------------------------------
# Internet Gateway
# ------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# ------------------------------------------------------------
# NAT Gateway (salida a internet desde las subredes privadas,
# necesaria para que los nodos descarguen imágenes desde ECR)
# ------------------------------------------------------------

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

# ------------------------------------------------------------
# Tablas de ruteo
# ------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

# ------------------------------------------------------------
# Security Group de los nodos EKS
# ------------------------------------------------------------

resource "aws_security_group" "eks_nodes" {
  name        = "${var.project_name}-eks-nodes-sg"
  description = "Trafico entre nodos EKS, el plano de control y el LoadBalancer publico"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Trafico interno entre nodos del cluster"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "NodePort para el Service tipo LoadBalancer (frontend)"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-eks-nodes-sg"
  }
}

# ------------------------------------------------------------
# EKS Cluster
# ------------------------------------------------------------

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = data.aws_iam_role.labrole.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.public_a.id,
      aws_subnet.public_b.id,
      aws_subnet.private_a.id,
      aws_subnet.private_b.id,
    ]

    security_group_ids      = [aws_security_group.eks_nodes.id]
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  tags = {
    Name  = var.cluster_name
    Stage = "EP3"
  }
}

# ------------------------------------------------------------
# EKS Node Group (en subredes privadas)
# ------------------------------------------------------------

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-workers"
  node_role_arn   = data.aws_iam_role.labrole.arn

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
  ]

  # t3.medium: mínimo recomendado para correr 2 apps Spring Boot + MySQL en k8s
  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"

  # En AWS Academy conviene partir con pocos nodos para evitar bloqueos de
  # cuota al crear el Node Group; max_size deja margen para escalar.
  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name  = "${var.project_name}-workers"
    Stage = "EP3"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_route_table_association.private_a,
    aws_route_table_association.private_b,
    aws_nat_gateway.nat,
  ]
}

# ------------------------------------------------------------
# ECR - Repositorios de imágenes Docker
# ------------------------------------------------------------

resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name  = "${var.project_name}-frontend"
    Stage = "EP3"
  }
}

resource "aws_ecr_repository" "backend_ventas" {
  name                 = "${var.project_name}-backend-ventas"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "${var.project_name}-backend-ventas"
    Stage   = "EP3"
    Service = "Ventas"
  }
}

resource "aws_ecr_repository" "backend_despachos" {
  name                 = "${var.project_name}-backend-despachos"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "${var.project_name}-backend-despachos"
    Stage   = "EP3"
    Service = "Despachos"
  }
}

# ------------------------------------------------------------
# CloudWatch Log Groups
# ------------------------------------------------------------

resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "app_frontend" {
  name              = "/${var.project_name}/frontend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "app_ventas" {
  name              = "/${var.project_name}/backend-ventas"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "app_despachos" {
  name              = "/${var.project_name}/backend-despachos"
  retention_in_days = 7
}
