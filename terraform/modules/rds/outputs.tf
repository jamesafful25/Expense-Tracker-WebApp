
output "db_instance_id" {
  description = "RDS database instance identifier"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "ARN of the RDS database instance"
  value       = aws_db_instance.main.arn
}

output "db_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_address" {
  description = "RDS database hostname"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "RDS database port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Application database name"
  value       = aws_db_instance.main.db_name
}

output "db_secret_arn" {
  description = "Secrets Manager ARN containing the RDS master credentials"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
  sensitive   = true
}

output "db_subnet_group_name" {
  description = "Name of the RDS subnet group"
  value       = aws_db_subnet_group.main.name
}
