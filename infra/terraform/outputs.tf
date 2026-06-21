output "cluster_name" {
  description = "Nombre del clúster EKS"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint del plano de control EKS"
  value       = aws_eks_cluster.main.endpoint
}

output "frontend_ecr_url" {
  description = "URL del repositorio ECR del Frontend"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_ventas_ecr_url" {
  description = "URL del repositorio ECR del Backend Ventas"
  value       = aws_ecr_repository.backend_ventas.repository_url
}

output "backend_despachos_ecr_url" {
  description = "URL del repositorio ECR del Backend Despachos"
  value       = aws_ecr_repository.backend_despachos.repository_url
}

output "kubeconfig_command" {
  description = "Comando para conectar kubectl al clúster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

output "github_secrets_to_create" {
  description = "Secrets necesarios en GitHub Actions"
  value       = <<-EOT
  Crea estos secrets en GitHub -> Settings -> Secrets and variables -> Actions:

  AWS_ACCESS_KEY_ID      -> desde AWS Academy (AWS Details -> Show)
  AWS_SECRET_ACCESS_KEY  -> desde AWS Academy
  AWS_SESSION_TOKEN      -> desde AWS Academy
  EOT
}
