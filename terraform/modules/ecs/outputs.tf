output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "task_definition_arn" {
  description = "ARN of the backend ECS task definition"
  value       = aws_ecs_task_definition.backend.arn
}

output "service_name" {
  description = "Name of the backend ECS service"
  value       = aws_ecs_service.backend.name
}

output "service_id" {
  description = "ID of the backend ECS service"
  value       = aws_ecs_service.backend.id
}

output "log_group_name" {
  description = "CloudWatch log group for backend containers"
  value       = aws_cloudwatch_log_group.backend.name
}