variable "aws_region" {
  description = "Región AWS del laboratorio AWS Academy"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre base para etiquetar y nombrar recursos AWS"
  type        = string
  default     = "innovatech-ep3"
}

variable "cluster_name" {
  description = "Nombre del clúster EKS"
  type        = string
  default     = "innovatech-cluster"
}
