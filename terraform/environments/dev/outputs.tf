output "vpc_id" {
  description = "ID of the development VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of private application subnets"
  value       = module.networking.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of private database subnets"
  value       = module.networking.private_db_subnet_ids
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.networking.nat_gateway_id
}

output "frontend_bucket_id" {
  description = "Frontend S3 bucket name"
  value       = module.frontend.frontend_bucket_id
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.cloudfront_distribution_id
}

output "cloudfront_distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.cloudfront_distribution_domain_name
}

output "ecr_repository_name" {
  description = "Name of the backend ECR repository"
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "URL of the backend ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the backend ECR repository"
  value       = module.ecr.repository_arn
}

# Application Load Balancer Outputs

output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = module.alb.alb_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "target_group_arn" {
  description = "ARN of the backend target group"
  value       = module.alb.target_group_arn
}


# Amazon RDS Outputs

output "db_instance_id" {
  description = "RDS database instance identifier"
  value       = module.rds.db_instance_id
}

output "db_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_endpoint
}

output "db_port" {
  description = "RDS database port"
  value       = module.rds.db_port
}

output "db_name" {
  description = "Application database name"
  value       = module.rds.db_name
}

output "db_secret_arn" {
  description = "Secrets Manager ARN containing RDS credentials"
  value       = module.rds.db_secret_arn
  sensitive   = true
}
