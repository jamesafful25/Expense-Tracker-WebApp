output "db_app_secret_arn" {
  description = "ARN of the application database credentials secret"
  value       = aws_secretsmanager_secret.db_app.arn
}

output "app_secrets_arn" {
  description = "ARN of the application secrets"
  value       = aws_secretsmanager_secret.app.arn
}