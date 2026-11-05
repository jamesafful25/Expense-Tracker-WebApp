
output "ecs_cpu_alarm_arn" {
  description = "ARN of the ECS CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.ecs_cpu_high.arn
}

output "ecs_memory_alarm_arn" {
  description = "ARN of the ECS memory utilization alarm"
  value       = aws_cloudwatch_metric_alarm.ecs_memory_high.arn
}

output "alb_unhealthy_targets_alarm_arn" {
  description = "ARN of the ALB unhealthy targets alarm"
  value       = aws_cloudwatch_metric_alarm.alb_unhealthy_targets.arn
}

output "alb_http_5xx_alarm_arn" {
  description = "ARN of the ALB HTTP 5XX errors alarm"
  value       = aws_cloudwatch_metric_alarm.alb_http_5xx.arn
}

output "rds_cpu_alarm_arn" {
  description = "ARN of the RDS CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.rds_cpu_high.arn
}

output "rds_low_storage_alarm_arn" {
  description = "ARN of the RDS low free storage alarm"
  value       = aws_cloudwatch_metric_alarm.rds_low_storage.arn
}
